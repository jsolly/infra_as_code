-- Common types and domains
CREATE DOMAIN timezone_type AS VARCHAR(50) CHECK (
    VALUE IN (
        'America/New_York',
        'America/Los_Angeles',
        'America/Chicago'
    )
);

CREATE DOMAIN temperature_type AS DECIMAL(5, 2) CHECK (
    VALUE BETWEEN -45
    AND 50
);

CREATE DOMAIN percentage_type AS INTEGER CHECK (
    VALUE BETWEEN 0
    AND 100
);

-- Common columns
CREATE
OR REPLACE FUNCTION create_timestamp_columns() RETURNS void AS $ $ BEGIN EXECUTE 'ALTER TABLE ' || TG_TABLE_NAME || ' 
    ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP';

END;

$ $ LANGUAGE plpgsql;

-- Tables with common types
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    preferred_name VARCHAR(100),
    preferred_language VARCHAR(50) CHECK (preferred_language IN ('en', 'es', 'fr')),
    city_of_residence VARCHAR(100) REFERENCES Cities(city_name) ON DELETE
    SET
        NULL,
        phone_number VARCHAR(20) UNIQUE NOT NULL CHECK (phone_number ~ '^\+[1-9]\d{1,14}$'),
        notification_time_zone timezone_type NOT NULL,
        daily_notification_time TIME,
        unit_preference VARCHAR(10) CHECK (unit_preference IN ('imperial', 'metric')),
        is_active BOOLEAN DEFAULT true
);

SELECT
    create_timestamp_columns();

CREATE TABLE Cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL UNIQUE CHECK (
        city_name IN ('New York', 'Los Angeles', 'Chicago')
    ),
    latitude DECIMAL(10, 8) NOT NULL CHECK (
        latitude >= -90
        AND latitude <= 90
    ),
    longitude DECIMAL(11, 8) NOT NULL CHECK (
        longitude >= -180
        AND longitude <= 180
    ),
    time_zone timezone_type NOT NULL,
    country VARCHAR(100) NOT NULL CHECK (country IN ('United States', 'Canada'))
);

SELECT
    create_timestamp_columns();

-- User_Cities join table
CREATE TABLE User_Cities (
    user_city_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(user_id) ON DELETE CASCADE,
    city_id INTEGER REFERENCES Cities(city_id) ON DELETE CASCADE,
);

-- CityWeather table
CREATE TABLE CityWeather (
    city_id INTEGER PRIMARY KEY REFERENCES Cities(city_id) ON DELETE CASCADE,
    weather_description TEXT NOT NULL,
    min_temperature temperature_type NOT NULL,
    max_temperature temperature_type NOT NULL,
    apparent_temperature temperature_type NOT NULL,
    relative_humidity percentage_type NOT NULL,
    cloud_coverage percentage_type NOT NULL,
    CONSTRAINT temperature_range_check CHECK (max_temperature >= min_temperature)
);

SELECT
    create_timestamp_columns();

-- NotificationPreferences table
CREATE TABLE NotificationPreferences (
    preference_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(user_id) ON DELETE CASCADE UNIQUE,
    daily_fullmoon BOOLEAN DEFAULT false,
    daily_nasa BOOLEAN DEFAULT false,
    daily_weather_outfit BOOLEAN DEFAULT true,
    daily_recipe BOOLEAN DEFAULT false,
    instant_sunset BOOLEAN DEFAULT false,
    daily_notification_time TIME CHECK (
        daily_notification_time BETWEEN '00:00:00'
        AND '23:59:59'
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

SELECT
    create_timestamp_columns();

-- Notifications_Log table
CREATE TABLE Notifications_Log (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(user_id) ON DELETE
    SET
        NULL,
        city_id INTEGER REFERENCES Cities(city_id) ON DELETE
    SET
        NULL,
        notification_time TIMESTAMP WITH TIME ZONE NOT NULL,
        sent_time TIMESTAMP WITH TIME ZONE,
        delivery_status VARCHAR(20) NOT NULL CHECK (
            delivery_status IN ('pending', 'sent', 'failed', 'delivered')
        ),
        response_message TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

SELECT
    create_timestamp_columns();

-- Add after all table creation statements
CREATE INDEX idx_users_phone ON Users(phone_number);

CREATE INDEX idx_cityweather_updated ON CityWeather(updated_at);

CREATE INDEX idx_notifications_log_time ON Notifications_Log(notification_time);

-- Single trigger function for all tables
CREATE
OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $ $ BEGIN NEW.updated_at = CURRENT_TIMESTAMP;

RETURN NEW;

END;

$ $ LANGUAGE plpgsql;

-- Create triggers for all tables with a single function
CREATE
OR REPLACE FUNCTION create_update_trigger(table_name text) RETURNS void AS $ $ BEGIN EXECUTE format(
    '
        CREATE TRIGGER update_%s_updated_at 
        BEFORE UPDATE ON %s 
        FOR EACH ROW 
        EXECUTE FUNCTION update_updated_at_column()',
    table_name,
    table_name
);

END;

$ $ LANGUAGE plpgsql;

-- Apply triggers to all tables
SELECT
    create_update_trigger('users');

SELECT
    create_update_trigger('cities');

SELECT
    create_update_trigger('city_weather');

SELECT
    create_update_trigger('notification_preferences');

SELECT
    create_update_trigger('notifications_log');