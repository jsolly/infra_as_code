-- Users table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    preferred_name VARCHAR(100),
    preferred_language VARCHAR(50) CHECK (preferred_language IN ('en', 'es', 'fr')),
    city_of_residence VARCHAR(100) REFERENCES Cities(city_name) ON DELETE
    SET
        NULL,
        phone_number VARCHAR(20) UNIQUE NOT NULL CHECK (phone_number ~ '^\+[1-9]\d{1,14}$'),
        notification_time_zone VARCHAR(50) NOT NULL CHECK (
            notification_time_zone IN (
                'America/New_York',
                'America/Los_Angeles',
                'America/Chicago'
            )
        ),
        daily_notification_time TIME,
        unit_preference VARCHAR(10) CHECK (unit_preference IN ('imperial', 'metric')),
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cities table
CREATE TABLE Cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL CHECK (
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
    time_zone VARCHAR(50) NOT NULL,
    country VARCHAR(100) NOT NULL CHECK (country IN ('United States', 'Canada')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User_Cities join table
CREATE TABLE User_Cities (
    user_city_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(user_id) ON DELETE CASCADE,
    city_id INTEGER REFERENCES Cities(city_id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- CityWeather table
CREATE TABLE CityWeather (
    city_id INTEGER PRIMARY KEY REFERENCES Cities(city_id) ON DELETE CASCADE,
    weather_description TEXT NOT NULL,
    min_temperature DECIMAL(5, 2) NOT NULL CHECK (
        min_temperature BETWEEN -100
        AND 150
    ),
    max_temperature DECIMAL(5, 2) NOT NULL CHECK (
        max_temperature BETWEEN -90
        AND 60
    ),
    apparent_temperature DECIMAL(5, 2) NOT NULL CHECK (
        apparent_temperature BETWEEN -90
        AND 60
    ),
    relative_humidity INTEGER NOT NULL CHECK (
        relative_humidity BETWEEN 0
        AND 100
    ),
    cloud_coverage INTEGER NOT NULL CHECK (
        cloud_coverage BETWEEN 0
        AND 100
    ),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);