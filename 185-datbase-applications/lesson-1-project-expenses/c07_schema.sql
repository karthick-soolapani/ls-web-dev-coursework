CREATE TABLE expenses (
  PRIMARY KEY (id),
  id SERIAL,
  amount NUMERIC(6,2) NOT NULL,
  memo TEXT NOT NULL,
  created_on DATE NOT NULL DEFAULT CURRENT_DATE
);

ALTER TABLE expenses
  ADD CONSTRAINT positive_amount CHECK (amount >= 0.01);