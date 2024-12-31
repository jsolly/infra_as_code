-- Users table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    notification_time_zone VARCHAR(50) NOT NULL,
    weather_subscription BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cities table
CREATE TABLE Cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    time_zone VARCHAR(50) NOT NULL,
    country VARCHAR(100),
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
    temperature DECIMAL(5, 2) NOT NULL,
    feels_like_temp DECIMAL(5, 2) NOT NULL,
    humidity INTEGER NOT NULL,
    cloud_coverage INTEGER NOT NULL,
    wind_speed DECIMAL(5, 2) NOT NULL,
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
        delivery_status VARCHAR(20) NOT NULL,
        response_message TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_active_subscription ON Users(is_active, weather_subscription);

CREATE INDEX idx_cities_name_country ON Cities(city_name, country);

CREATE INDEX idx_user_cities_lookup ON User_Cities(user_id, city_id);

CREATE INDEX idx_notifications_status ON Notifications_Log(delivery_status);

-- Create trigger for updated_at timestamps
CREATE
OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $ $ BEGIN NEW.updated_at = CURRENT_TIMESTAMP;

RETURN NEW;

END;

$ $ language 'plpgsql';

-- Apply trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE
UPDATE
    ON Users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cities_updated_at BEFORE
UPDATE
    ON Cities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_cities_updated_at BEFORE
UPDATE
    ON User_Cities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();