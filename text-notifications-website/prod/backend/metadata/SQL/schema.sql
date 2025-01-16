-- Common types and domains
CREATE DOMAIN timezone_type AS VARCHAR(50) CHECK (
    VALUE IN (
        'America/New_York',
        'America/Los_Angeles',
        'America/Chicago'
    )
);

CREATE DOMAIN city_name_type AS VARCHAR(100) CHECK (VALUE IN ('New York', 'Los Angeles', 'Chicago'));

CREATE DOMAIN country_type AS VARCHAR(100) CHECK (VALUE IN ('United States', 'Canada'));

CREATE DOMAIN temperature_type AS DECIMAL(5, 2) CHECK (VALUE BETWEEN -45 AND 50);

CREATE DOMAIN percentage_type AS INTEGER CHECK (VALUE BETWEEN 0 AND 100);

CREATE DOMAIN language_type AS VARCHAR(50) CHECK (VALUE IN ('en', 'es', 'fr'));

CREATE DOMAIN unit_type AS VARCHAR(10) CHECK (VALUE IN ('imperial', 'metric'));

CREATE DOMAIN delivery_status_type AS VARCHAR(20) CHECK (
    VALUE IN ('pending', 'sent', 'failed', 'delivered')
);

-- Common columns
CREATE OR REPLACE FUNCTION create_timestamp_columns () RETURNS void AS $$ BEGIN EXECUTE 'ALTER TABLE ' || TG_TABLE_NAME || ' 
    ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP';

END;

$$ LANGUAGE plpgsql;

-- Tables with common types
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    preferred_name VARCHAR(100),
    preferred_language language_type NOT NULL DEFAULT 'en',
    city_of_residence INTEGER REFERENCES Cities (city_id) ON DELETE SET NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL CHECK (phone_number ~ '^\+[1-9]\d{1,14}$'),
    notification_time_zone timezone_type NOT NULL,
    daily_notification_time TIME NOT NULL,
    unit_preference unit_type NOT NULL DEFAULT 'metric',
    is_active BOOLEAN NOT NULL DEFAULT true
);

SELECT
    create_timestamp_columns ();

CREATE TABLE Cities (
    city_id SERIAL PRIMARY KEY,
    city_name city_name_type NOT NULL UNIQUE,
    latitude DECIMAL(10, 8) NOT NULL CHECK (
        latitude >= -90
        AND latitude <= 90
    ),
    longitude DECIMAL(11, 8) NOT NULL CHECK (
        longitude >= -180
        AND longitude <= 180
    ),
    time_zone timezone_type NOT NULL,
    country country_type NOT NULL
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

-- Add after all table creation statements
CREATE INDEX idx_users_phone ON Users (phone_number);

CREATE INDEX idx_cityweather_updated ON CityWeather (updated_at);

CREATE INDEX idx_notifications_log_time ON Notifications_Log (notification_time);

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