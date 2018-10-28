DROP TABLE IF EXISTS copyrights;
DROP TABLE IF EXISTS scientists;
DROP TABLE IF EXISTS devices;

CREATE TABLE scientists (
	id SERIAL NOT NULL,
	name varchar(40) NOT NULL UNIQUE,
	madness int NOT NULL,                                   -- measure of madness
	tries int NOT NULL,                                     -- number of tries to destroy the galaxy
	timestamp timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- date and time of adding information
	PRIMARY KEY (id),
	CONSTRAINT not_negative_madness CHECK (madness >= 0),
	CONSTRAINT not_negative_tries CHECK (tries >= 0)
);

CREATE TABLE devices (
	id SERIAL NOT NULL,
	name varchar(40) NOT NULL UNIQUE,
	power int NOT NULL,                                     -- measure of destructive power
	timestamp timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- date and time of adding information
	PRIMARY KEY (id),
	CONSTRAINT not_negative_power CHECK (power >= 0)
);

CREATE TABLE copyrights (
	scientist_id int NOT NULL REFERENCES scientists ON DELETE CASCADE,
	device_id int NOT NULL REFERENCES devices ON DELETE CASCADE,
	PRIMARY KEY (scientist_id, device_id)
);
