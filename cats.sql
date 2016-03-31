CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  cats (id, name, owner_id)
VALUES
  (1, "Garfield", 1),
  (2, "Snowball", 2),
  (3, "Coltrane", 2),
  (4, "Isis", 3),
  (5, "Top Cat", NULL);

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "John", "Arbuckle", 1),
  (2, "Lisa", "Simpson", 2),
  (3, "Selina", "Kyle", 3),
  (4, "Bruce", "Wayne", 4);

INSERT INTO
  houses (id, address)
VALUES
  (1, "711 Maple Street"),
  (2, "742 Evergreen Terrace"),
  (3, "East End, Gotham City"),
  (4, "Wayne Manor, Gotham City");
