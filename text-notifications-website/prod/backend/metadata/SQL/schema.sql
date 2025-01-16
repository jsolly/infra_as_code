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

/*==============================================================*/
/* REFERENCE & SUPPORT TABLES                                    */
/*==============================================================*/
CREATE TABLE SupportedTimezones (
    timezone_id SERIAL PRIMARY KEY,
    timezone_name VARCHAR(50) NOT NULL UNIQUE CHECK (timezone_name ~ '^[A-Za-z]+/[A-Za-z_]+$'),
    display_name VARCHAR(100) NOT NULL,
    utc_offset INTERVAL NOT NULL,
    is_active BOOLEAN DEFAULT true,
    CONSTRAINT valid_timezone CHECK (NOW() AT TIME ZONE timezone_name IS NOT NULL)
);

SELECT
    create_timestamp_columns ();

CREATE TABLE SupportedCountries (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true
);

SELECT
    create_timestamp_columns ();

CREATE TABLE SupportedCities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_code CHAR(2) REFERENCES SupportedCountries (country_code),
    is_active BOOLEAN DEFAULT true,
    UNIQUE (city_name, country_code)
);

SELECT
    create_timestamp_columns ();

-- Indexes for support tables
CREATE INDEX idx_supported_timezones_active ON SupportedTimezones (is_active)
WHERE
    is_active = true;

CREATE INDEX idx_supported_cities_country ON SupportedCities (country_code);

CREATE INDEX idx_supported_cities_active ON SupportedCities (is_active)
WHERE
    is_active = true;

CREATE INDEX idx_supported_countries_active ON SupportedCountries (is_active)
WHERE
    is_active = true;

/*==============================================================*/
/* CORE APPLICATION TABLES                                       */
/*==============================================================*/
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    preferred_name VARCHAR(100),
    preferred_language language_type NOT NULL DEFAULT 'en',
    city_of_residence INTEGER REFERENCES Cities (city_id) ON DELETE SET NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL CHECK (phone_number ~ '^\+[1-9]\d{1,14}$'),
    notification_timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id),
    daily_notification_time TIME NOT NULL,
    unit_preference unit_type NOT NULL DEFAULT 'metric',
    is_active BOOLEAN NOT NULL DEFAULT true
);

SELECT
    create_timestamp_columns ();

-- Cities table
CREATE TABLE Cities (
    city_id SERIAL PRIMARY KEY,
    supported_city_id INTEGER NOT NULL REFERENCES SupportedCities (city_id),
    latitude DECIMAL(10, 8) NOT NULL CHECK (
        latitude >= -90
        AND latitude <= 90
    ),
    longitude DECIMAL(11, 8) NOT NULL CHECK (
        longitude >= -180
        AND longitude <= 180
    ),
    timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id),
    country_code CHAR(2) NOT NULL REFERENCES SupportedCountries (country_code)
);

SELECT
    create_timestamp_columns ();

-- User_Cities join table
CREATE TABLE User_Cities (
    user_city_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
    city_id INTEGER NOT NULL REFERENCES Cities (city_id) ON DELETE CASCADE
);

-- CityWeather table
CREATE TABLE CityWeather (
    city_id INTEGER PRIMARY KEY REFERENCES Cities (city_id) ON DELETE CASCADE,
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
    preference_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE UNIQUE,
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
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users (user_id) ON DELETE SET NULL,
    city_id INTEGER REFERENCES Cities (city_id) ON DELETE SET NULL,
    notification_time TIMESTAMP WITH TIME ZONE NOT NULL,
    sent_time TIMESTAMP WITH TIME ZONE,
    delivery_status delivery_status_type NOT NULL DEFAULT 'pending',
    response_message TEXT
);

SELECT
    create_timestamp_columns ();

/*==============================================================*/
/* INDEXES                                                       */
/*==============================================================*/
-- Index for querying users by phone number
CREATE INDEX idx_users_phone ON Users (phone_number);

-- Index for querying city weather by city ID
CREATE INDEX idx_cityweather_updated ON CityWeather (updated_at);

-- Index for querying notifications by notification time
CREATE INDEX idx_notifications_log_time ON Notifications_Log (notification_time);

-- Index for querying notification preferences by user ID
CREATE INDEX idx_notification_prefs_user ON NotificationPreferences (user_id);

-- Index for querying notifications by delivery status and notification time
CREATE INDEX idx_notifications_status_time ON Notifications_Log (delivery_status, notification_time);

/*==============================================================*/
/* TRIGGERS & FUNCTIONS                                          */
/*==============================================================*/
-- Single trigger function for all tables
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

CREATE INDEX idx_notification_preferences_user ON NotificationPreferences (user_id);

-- Add triggers for the new tables
CREATE TRIGGER update_supported_countries_updated_at BEFORE
UPDATE ON SupportedCountries FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

CREATE TRIGGER update_supported_cities_updated_at BEFORE
UPDATE ON SupportedCities FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column ();

-- Add indexes for the new tables
CREATE INDEX idx_supported_cities_country ON SupportedCities (country_code);

CREATE INDEX idx_supported_cities_active ON SupportedCities (is_active)
WHERE
    is_active = true;

CREATE INDEX idx_supported_countries_active ON SupportedCountries (is_active)
WHERE
    is_active = true;

-- Update Cities table to reference SupportedTimezones
ALTER TABLE Cities
DROP COLUMN time_zone,
ADD COLUMN timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id);

-- Update Users table to reference SupportedTimezones
ALTER TABLE Users
DROP COLUMN notification_time_zone,
ADD COLUMN notification_timezone_id INTEGER NOT NULL REFERENCES SupportedTimezones (timezone_id);