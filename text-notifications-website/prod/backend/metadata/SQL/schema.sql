/*==============================================================*/
/* DOMAINS & CUSTOM TYPES                                        */
/*==============================================================*/
-- Temperatures are in Celsius (Convert to Fahrenheit during runtime/client/display if needed)
-- Approximately -49°F to 122°F (Don't expect temperatures outside of this range!)
CREATE DOMAIN temperature_type AS DECIMAL(5, 2) CHECK (VALUE BETWEEN -45 AND 50);

CREATE DOMAIN percentage_type AS INTEGER CHECK (VALUE BETWEEN 0 AND 100);

CREATE DOMAIN language_type AS VARCHAR(5) CHECK (
    VALUE IN (
        'en',
        'es',
        'fr',
        'en-US',
        'en-CA',
        'es-US',
        'fr-CA'
    )
);

CREATE DOMAIN unit_type AS VARCHAR(10) CHECK (VALUE IN ('imperial', 'metric'));

CREATE DOMAIN delivery_status_type AS VARCHAR(20) CHECK (
    VALUE IN ('pending', 'sent', 'failed', 'delivered')
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

/*==============================================================*/
/* REFERENCE & SUPPORT TABLES                                    */
/*==============================================================*/
-- TODO (Use postgres timezone definitions instead of a custom table)
CREATE TABLE SupportedTimezones (
    timezone_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    timezone_name VARCHAR(50) NOT NULL UNIQUE CHECK (
        timezone_name ~ '^(Africa|America|Antarctica|Asia|Atlantic|Australia|Europe|Indian|Pacific)/[A-Za-z0-9/_-]+$'
    ),
    display_name VARCHAR(100) NOT NULL,
    utc_offset INTERVAL NOT NULL,
    CONSTRAINT valid_timezone CHECK (NOW() AT TIME ZONE timezone_name IS NOT NULL)
);

SELECT
    create_timestamp_columns ();

CREATE TABLE SupportedCountries (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL
);

SELECT
    create_timestamp_columns ();

CREATE TABLE SupportedCities (
    city_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    city_name VARCHAR(100) NOT NULL,
    country_code CHAR(2) REFERENCES SupportedCountries (country_code),
    UNIQUE (city_name, country_code)
);

SELECT
    create_timestamp_columns ();

/*==============================================================*/
/* CORE APPLICATION TABLES                                       */
/*==============================================================*/
CREATE TABLE Users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    preferred_name VARCHAR(100),
    preferred_language language_type NOT NULL DEFAULT 'en',
    phone_number VARCHAR(20) UNIQUE NOT NULL CHECK (
        phone_number ~ '^\+[1-9]\d{6,14}$'
        AND -- Minimum 7 digits, maximum 15 digits
        length(phone_number) <= 16 -- Total length including '+' sign
    ),
    notification_timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id),
    unit_preference unit_type NOT NULL DEFAULT 'metric',
    is_active BOOLEAN NOT NULL DEFAULT true
);

SELECT
    create_timestamp_columns ();

-- Cities table
CREATE TABLE Cities (
    city_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    supported_city_id UUID NOT NULL REFERENCES SupportedCities (city_id),
    latitude NUMERIC(9, 6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude NUMERIC(9, 6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id),
    country_code CHAR(2) NOT NULL REFERENCES SupportedCountries (country_code)
);

SELECT
    create_timestamp_columns ();

-- User_Cities join table
CREATE TABLE User_Cities (
    user_city_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    user_id UUID NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
    city_id UUID NOT NULL REFERENCES Cities (city_id) ON DELETE CASCADE,
    CONSTRAINT user_city_unique UNIQUE (user_id, city_id) -- Prevent duplicate user-city pairs
);

-- CityWeather table
CREATE TABLE CityWeather (
    city_id UUID PRIMARY KEY REFERENCES Cities (city_id) ON DELETE CASCADE,
    weather_description TEXT NOT NULL,
    min_temperature temperature_type NOT NULL,
    max_temperature temperature_type NOT NULL,
    apparent_temperature temperature_type NOT NULL,
    relative_humidity percentage_type NOT NULL,
    cloud_coverage percentage_type NOT NULL,
    CONSTRAINT temperature_range_check CHECK (max_temperature >= min_temperature)
);

SELECT
    create_timestamp_columns ();

-- NotificationPreferences table
CREATE TABLE NotificationPreferences (
    user_id UUID PRIMARY KEY REFERENCES Users (user_id) ON DELETE CASCADE,
    daily_fullmoon BOOLEAN NOT NULL DEFAULT false,
    daily_nasa BOOLEAN NOT NULL DEFAULT false,
    daily_weather_outfit BOOLEAN NOT NULL DEFAULT true,
    daily_recipe BOOLEAN NOT NULL DEFAULT false,
    instant_sunset BOOLEAN NOT NULL DEFAULT false,
    daily_notification_time TIME NOT NULL
);

SELECT
    create_timestamp_columns ();

-- Notifications_Log table
CREATE TABLE Notifications_Log (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    user_id UUID REFERENCES Users (user_id) ON DELETE SET NULL,
    city_id UUID REFERENCES Cities (city_id) ON DELETE SET NULL,
    notification_time TIMESTAMP WITH TIME ZONE NOT NULL,
    sent_time TIMESTAMP WITH TIME ZONE,
    delivery_status delivery_status_type NOT NULL DEFAULT 'pending',
    response_message TEXT
);

SELECT
    create_timestamp_columns ();

-- Update table structures to use support tables
ALTER TABLE Cities
DROP COLUMN time_zone,
ADD COLUMN timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id);

ALTER TABLE Users
DROP COLUMN notification_time_zone,
ADD COLUMN notification_timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id);

/*==============================================================*/
/* INDEXES                                                       */
/*==============================================================*/
-- When querying users by phone number
CREATE INDEX idx_users_phone ON Users (phone_number);

-- When querying city weather by updated_at
CREATE INDEX idx_cityweather_updated ON CityWeather (updated_at);

-- When querying notifications by notification_time
CREATE INDEX idx_notifications_log_time ON Notifications_Log (notification_time);

-- When querying notification preferences by user_id
CREATE INDEX idx_notification_prefs_user ON NotificationPreferences (user_id);

-- When querying notifications by delivery_status and notification_time
CREATE INDEX idx_notifications_status_time ON Notifications_Log (delivery_status, notification_time);

-- When querying notification preferences by user_id
CREATE INDEX idx_notification_preferences_user ON NotificationPreferences (user_id);

-- Add index on Notifications_Log.user_id
CREATE INDEX idx_notifications_log_user_id ON Notifications_Log (user_id);

-- Add index on User_Cities.user_id and User_Cities.city_id
CREATE INDEX idx_user_cities_user_id ON User_Cities (user_id);

CREATE INDEX idx_user_cities_city_id ON User_Cities (city_id);

/*==============================================================*/
/* TRIGGERS & FUNCTIONS                                          */
/*==============================================================*/
-- Single trigger function for all tables that need to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column () RETURNS TRIGGER AS $$
BEGIN 
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE
UPDATE ON Users FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

CREATE TRIGGER update_cities_updated_at BEFORE
UPDATE ON Cities FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

CREATE TRIGGER update_city_weather_updated_at BEFORE
UPDATE ON CityWeather FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

CREATE TRIGGER update_notification_preferences_updated_at BEFORE
UPDATE ON NotificationPreferences FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

CREATE TRIGGER update_notifications_log_updated_at BEFORE
UPDATE ON Notifications_Log FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

CREATE TRIGGER update_supported_countries_updated_at BEFORE
UPDATE ON SupportedCountries FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

CREATE TRIGGER update_supported_cities_updated_at BEFORE
UPDATE ON SupportedCities FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();