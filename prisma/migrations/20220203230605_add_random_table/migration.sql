--- Add view for getting random value

CREATE VIEW [dbo].[random]
AS
	SELECT CRYPT_GEN_RANDOM(4) AS random_value;
