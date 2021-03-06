
-- Step 1 C Create MSSQL sample database
USE master
GO

IF DB_ID('TestDb') IS NOT NULL
    DROP DATABASE [TestDb]
GO

CREATE DATABASE [TestDb];
GO

-- Step 2 C Create Test Table, init data & verify
USE [TestDb]
GO

IF OBJECT_ID('dbo.CustomerInfo', 'U') IS NOT NULL
    DROP TABLE dbo.CustomerInfo
GO

CREATE TABLE dbo.CustomerInfo (
	CustomerId INT IDENTITY(10000,1) NOT NULL PRIMARY KEY,
	CustomerName VARCHAR(100) NOT NULL,
	CustomerPhone CHAR(11) NOT NULL
)
GO

-- Init Table
INSERT INTO dbo.CustomerInfo 
	VALUES	('CustomerA','13402872514'),
			('CustomerB','13880674722'),
			('CustomerC','13487759293')
GO

-- Verify data
SELECT * FROM dbo.CustomerInfo
GO

--CustomerId	CustomerName	CustomerPhone
--10000			CustomerA	13402872514
--10001			CustomerB	13880674722
--10002			CustomerC	13487759293


-- In the original data, user phone numbers are stored in plaintext, which means that whoever 
-- has access to the table data can get the phone numbers, as shown below:

--Create Instance-Level Master Keys
--Create Master Keys at the instance level in the SQL Server database (under the Master database 
-- by using the CREATE MASTER KEY statement):

-- NOTA : sihiciera falta

-- Step 3 C Create SQL Server Service Master Key
USE master
GO

IF NOT EXISTS (
    SELECT *
		FROM sys.symmetric_keys
		WHERE name = '##MS_ServiceMasterKey##'
) BEGIN
    CREATE MASTER KEY ENCRYPTION BY 
		PASSWORD = 'MSSQLSerivceMasterKey'
END
GO

--Create Database-Level Master Keys
--Under TestDb in the user database, create Master Keys:

-- Step 4 C Create MSSQL Database level master key
USE [TestDb]
GO

IF NOT EXISTS (
	SELECT * FROM sys.symmetric_keys 
		WHERE name LIKE '%MS_DatabaseMasterKey%'
) BEGIN        
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Abcd1234.';
END
GO

-- Create Asymmetric Keys
-- Under the user database, create asymmetric keys and encrypt them with a password:

-- Step 5 C Create MSSQL asymmetric Key
USE [TestDb]
GO

IF NOT EXISTS (SELECT * 
                FROM sys.asymmetric_keys 
                WHERE name = 'AsymKey_TestDb'
) BEGIN
    CREATE ASYMMETRIC KEY AsymKey_TestDb 
		WITH ALGORITHM = RSA_2048 
		ENCRYPTION BY PASSWORD = 'Abcd1234.'
END
GO

-- MASTER KEY SQL SERVER (SYMETRIC) (encripta claves) > 
--	MASTER KEY BD (SYMETRIC) (encripta claves) > ASSYMETRIC KEY DB (encripta informaci�n)

-- View Asymmetric Keys
-- You can use the following query statement to view asymmetric keys:
USE [TestDb]
GO

SELECT * FROM  sys.asymmetric_keys
GO

-- You can also use SSMS GUIs to view certificates and asymmetric key objects by choosing 
-- Security > Certificates > Asymmetric Keys under the user database

-- Modify Table Structure
-- Next we need to modify the table structure and add a new column of type varbinary(max) 
-- for storing encrypted phone number ciphertext (assume that we name the new column 
-- �EncryptedCustomerPhone�).

-- Step 6 C Change your table structure
USE [TestDb]
GO 

ALTER TABLE CustomerInfo 
	ADD EncryptedCustomerPhone varbinary(MAX) NULL
GO

SELECT * FROM CustomerInfo
GO

-- Initialize Data in the New Column
-- After the new column is added, we encrypt the archived data in the CustomerPhone 
-- column of the table into ciphertext and store it in the new column EncryptedCustomerPhone. 
-- We do so by using the EncryptByAsymKey function to encrypt the CustomerPhone column, as 
-- shown in the following statements:

-- Step 7 C init the encrypted data into the newly column
USE [TestDb]
GO

UPDATE dbo.CustomerInfo
SET 
	EncryptedCustomerPhone = ENCRYPTBYASYMKEY(ASYMKEY_ID('AsymKey_TestDb'), CustomerPhone)
GO

-- (3 rows affected)

-- Double-check the encrypted data of the new column
SELECT * FROM dbo.CustomerInfo
GO

-- We can see that the data in the EncryptedCustomerPhone column of the table has become the ciphertext data of the CustomerPhone column after encryption using the asymmetric keys, as show in the following screenshot:

--CustomerId	CustomerName	CustomerPhone	EncryptedCustomerPhone
--10000	CustomerA	13402872514	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D
--10001	CustomerB	13880674722	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9
--10002	CustomerC	13487759293	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290

-- View Encrypted Data
-- After phone numbers are encrypted into ciphertext, we need to use the DecryptByAsymKey 
-- function to decrypt them into plaintext. Let us see whether we can successfully 
-- decrypt the EncryptedCustomerPhone field.

-- Step 8 C Reading the SQL Server encrypted data
USE [TestDb]
GO

-- Now, it is time to list the original phone number, encrypted phone number, and decrypted phone number.
SELECT 
    *,
    DecryptedCustomerPhone = CONVERT(
		CHAR(11), 
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'), 
			EncryptedCustomerPhone, 
			N'Password4@Asy'
		)
	)
	FROM dbo.CustomerInfo
GO

-- Bad Password

--Msg 15466, Level 16, State 9, Line 129
--An error occurred during decryption.

SELECT 
    *,
    DecryptedCustomerPhone = CONVERT(
		CHAR(11), 
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'), 
			EncryptedCustomerPhone, 
			'Abcd1234.'
		)
	)
	FROM dbo.CustomerInfo
GO

-- Without
--  N'Abcd1234.'

--Msg 8116, Level 16, State 1, Line 140
--Argument data type varchar is invalid for argument 3 of DecryptByAsymKey function.

SELECT 
    *,
    DecryptedCustomerPhone = CONVERT(
		CHAR(11), 
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'), 
			EncryptedCustomerPhone, 
			N'Abcd1234.'
		)
	)
	FROM dbo.CustomerInfo
GO

-- The query statement shows the following results, where data in the CustomerPhone column and the DecryptedCustomerPhone column is identical, indicating that the encryption and decryption are successful.

--CustomerId	CustomerName	CustomerPhone	EncryptedCustomerPhone	DecryptedCustomerPhone
--10000	CustomerA	13402872514	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D	13402872514
--10001	CustomerB	13880674722	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9	13880674722
--10002	CustomerC	13487759293	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290	13487759293


-- --- PAUSAAAAAAAAAAAAAAAAA --------------------------------------------------------------


-- Adding New Data
-- Now that the archived data is identical after the encryption and decryption, 
-- let us see what happens if new data is added:

-- Step 9 C What if we add a new record to the table.
USE [TestDb]
GO

-- Performs the update of the record
INSERT INTO dbo.CustomerInfo (CustomerName, CustomerPhone, EncryptedCustomerPhone)
	VALUES (
		'CustomerD',
		'13880975623',
		ENCRYPTBYASYMKEY( ASYMKEY_ID('AsymKey_TestDb'), '13880975623')
	) 
GO

SELECT * FROM dbo.CustomerInfo
GO

--CustomerId	CustomerName	CustomerPhone	EncryptedCustomerPhone
--10000	CustomerA	13402872514	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D
--10001	CustomerB	13880674722	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9
--10002	CustomerC	13487759293	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290
--10003	CustomerD	13880975623	0x442CFB5B57CBA254F2BEC696BC979A75F9B2E0315FF3E078C251FF9BCD22D8452BE317EAFE3C457FA8E845B5F9C891A119399065B8E10F1A344F90C08B46C4EB5E780C016A3ED97DD7F79B8DE87E8749EB72461CE5E7C7AEA4F1DE5B10C2EA76799BA69EB199EA00129DD20E6C4C10630077E025D332192F558FFB2B597E9F4716EC52FA7E609ACDA3D98835A0448210AD19D43622261F6003B81CE9E674AB8E8903C35E9919BA415A8407F2539466063827875BA6AB9530FAF3D50B021AE025CD875D65416E411031034EAB2BA7D40423BA2764AE6D31DCF30966ED52F469FECE23827D00BC2EE6B7B0DC3E34CA673FD501A82A56C8F3E53CA38A515AB9B6A8

-- Update Phone Numbers
-- Now, we try to update user phone numbers:

-- Step 10 C So, what if we update the phone number
USE [TestDb]
GO 

-- Performs the update of the record
UPDATE dbo.CustomerInfo
	SET 
		EncryptedCustomerPhone = ENCRYPTBYASYMKEY(ASYMKEY_ID('AsymKey_TestDb'), '13880971234')
	WHERE CONVERT(
		CHAR(11), 
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'),
			EncryptedCustomerPhone,
			N'Abcd1234.')
		) = '13880975623'
GO

SELECT * FROM dbo.CustomerInfo
GO

--CustomerId	CustomerName	CustomerPhone	EncryptedCustomerPhone
--10000	CustomerA	13402872514	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D
--10001	CustomerB	13880674722	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9
--10002	CustomerC	13487759293	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290
--10003	CustomerD	13880975623	0x33E3569D2BE64BB7F354345CF62A971A3450B86C26790A1D50A64C1DB2949114C22386CCD9B7680A5E63DA92D7E91F9D217ED87B82923E167B0BAEBDC718BCA6167182D311F1AE172B922E03CB727A72AFAA02A4788280C28C668F5498F9C1180147380149149F0777D36845EC9C23A08775645E9F043A81A2D375C5E5C1EB2626F67D3DAC82A1E2042D556B2D76AE1EC429510DCBC643D682D53201D828F58B8462696FDC528D877FC22F559E809CED744E8058B929B6AD7ABFE8F8963C09ED78F6E06A47E8D3B40A7F29A2793C08ECCC06DC3651E98BF8E05C63A566FE32FDA8F55928E66072A62C4B1D5F775A2DD7DCBD4EC140D3B8196AEEB32A0C68B016


-- Delete the Phone Number Plaintext Column
-- Assuming everything goes as expected, we can delete the plaintext phone number column �CustomerPhone�:

-- Step 11 C Remove old column
USE [TestDb]
GO 

ALTER TABLE CustomerInfo
	DROP COLUMN CustomerPhone;
GO

SELECT * FROM CustomerInfo
GO

SELECT 
    *,
    DecryptedCustomerPhone = CONVERT(
		CHAR(11),
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'), 
			EncryptedCustomerPhone,
			N'Abcd1234.'
		)
	)
	FROM dbo.CustomerInfo
GO

--CustomerId	CustomerName	EncryptedCustomerPhone	DecryptedCustomerPhone
--10000	CustomerA	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D	13402872514
--10001	CustomerB	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9	13880674722
--10002	CustomerC	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290	13487759293
--10003	CustomerD	0x33E3569D2BE64BB7F354345CF62A971A3450B86C26790A1D50A64C1DB2949114C22386CCD9B7680A5E63DA92D7E91F9D217ED87B82923E167B0BAEBDC718BCA6167182D311F1AE172B922E03CB727A72AFAA02A4788280C28C668F5498F9C1180147380149149F0777D36845EC9C23A08775645E9F043A81A2D375C5E5C1EB2626F67D3DAC82A1E2042D556B2D76AE1EC429510DCBC643D682D53201D828F58B8462696FDC528D877FC22F559E809CED744E8058B929B6AD7ABFE8F8963C09ED78F6E06A47E8D3B40A7F29A2793C08ECCC06DC3651E98BF8E05C63A566FE32FDA8F55928E66072A62C4B1D5F775A2DD7DCBD4EC140D3B8196AEEB32A0C68B016	13880971234

-- The archived data, the newly added data, the updated data, and everything go as expected. 
-- Theoretically, this article could end at this point.

-- However, two questions remain. 
-- Can a newly created user access the table data? 
-- If not, how can we grant the new user access to the table data?

-- Adding a New User
-- Assume that we add a new user named EncryptedDbo:

-- Step 12 C Create a new user and access the encrypted data
USE [TestDb]
GO

CREATE LOGIN EncryptedDbo
    WITH PASSWORD = N'Abcd1234.',
	CHECK_POLICY = OFF
GO

CREATE USER EncryptedDbo FOR LOGIN EncryptedDbo
GO

GRANT SELECT ON OBJECT::dbo.CustomerInfo TO EncryptedDbo
GO

--Query Data as a New User
--We use the newly created user and open a new connection in SSMS to query data 
-- Authentication SQL server
-- NEW SESSION 

SELECT SYSTEM_USER
GO

/*EXECUTE AS USER = 'DOMBD\clientedb'
GO*/

-- EncryptedDbo
USE [TestDb]
GO

SELECT 
    *,
    DecryptedCustomerPhone = CONVERT(
		CHAR(11),
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'), 
			EncryptedCustomerPhone,
			N'Abcd1234.')
		)
	FROM dbo.CustomerInfo
GO

-- This new user cannot successfully decrypt the EncryptedCustomerPhone. 
-- The decrypted value of the DecryptedCustomerPhone field is NULL. 
-- This means that new users cannot view the user phone numbers in plaintext, 
-- preventing unknown users from getting such core data.

-- OUTCOME NULL

--CustomerId	CustomerName	EncryptedCustomerPhone	DecryptedCustomerPhone
--10000	CustomerA	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D	NULL
--10001	CustomerB	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9	NULL
--10002	CustomerC	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290	NULL
--10003	CustomerD	0x33E3569D2BE64BB7F354345CF62A971A3450B86C26790A1D50A64C1DB2949114C22386CCD9B7680A5E63DA92D7E91F9D217ED87B82923E167B0BAEBDC718BCA6167182D311F1AE172B922E03CB727A72AFAA02A4788280C28C668F5498F9C1180147380149149F0777D36845EC9C23A08775645E9F043A81A2D375C5E5C1EB2626F67D3DAC82A1E2042D556B2D76AE1EC429510DCBC643D682D53201D828F58B8462696FDC528D877FC22F559E809CED744E8058B929B6AD7ABFE8F8963C09ED78F6E06A47E8D3B40A7F29A2793C08ECCC06DC3651E98BF8E05C63A566FE32FDA8F55928E66072A62C4B1D5F775A2DD7DCBD4EC140D3B8196AEEB32A0C68B016	NULL


-- But if  Impersonate:

EXECUTE AS USER = 'EncryptedDbo'
GO

SELECT SYSTEM_USER
GO

SELECT 
    *,
    DecryptedCustomerPhone = CONVERT(
		CHAR(11), 
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'), 
			EncryptedCustomerPhone, 
			N'Abcd1234.'
		)
	)
	FROM dbo.CustomerInfo
GO

--CustomerId	CustomerName	EncryptedCustomerPhone	DecryptedCustomerPhone
--10000	CustomerA	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D	13402872514
--10001	CustomerB	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9	13880674722
--10002	CustomerC	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290	13487759293
--10003	CustomerD	0x33E3569D2BE64BB7F354345CF62A971A3450B86C26790A1D50A64C1DB2949114C22386CCD9B7680A5E63DA92D7E91F9D217ED87B82923E167B0BAEBDC718BCA6167182D311F1AE172B922E03CB727A72AFAA02A4788280C28C668F5498F9C1180147380149149F0777D36845EC9C23A08775645E9F043A81A2D375C5E5C1EB2626F67D3DAC82A1E2042D556B2D76AE1EC429510DCBC643D682D53201D828F58B8462696FDC528D877FC22F559E809CED744E8058B929B6AD7ABFE8F8963C09ED78F6E06A47E8D3B40A7F29A2793C08ECCC06DC3651E98BF8E05C63A566FE32FDA8F55928E66072A62C4B1D5F775A2DD7DCBD4EC140D3B8196AEEB32A0C68B016	13880971234

REVERT
GO

-- Granting Permission to a New User
-- A newly added user has no permission to view an encrypted column. To grant a 
-- newly added user permission to view data in an encrypted column, we can use the 
-- following statements:

--Step 14 C Grant permissions to EncryptedDbo
USE [TestDb]
GO

GRANT VIEW DEFINITION ON 
    ASYMMETRIC KEY::[AsymKey_TestDb] TO [EncryptedDbo]
GO

GRANT CONTROL ON 
    ASYMMETRIC KEY::[AsymKey_TestDb] TO [EncryptedDbo]
GO

-- Querying Data Again as a New User
-- After the required permission is granted, the new user can get the plaintext 
-- data in the encrypted column if the user runs the query statement in the 
-- �Query data as a new user� section.

-- Step 13 C OPEN a new connection query window using the new user and query data 

EXECUTE AS USER = 'EncryptedDbo'
GO

SELECT SYSTEM_USER
GO

USE [TestDb]
GO

SELECT 
    *,
    DecryptedCustomerPhone = CONVERT(
		CHAR(11),
		DECRYPTBYASYMKEY(
			ASYMKEY_ID('AsymKey_TestDb'), 
			EncryptedCustomerPhone,
			N'Abcd1234.'
		)
	)
	FROM dbo.CustomerInfo
GO

--CustomerId	CustomerName	EncryptedCustomerPhone	DecryptedCustomerPhone
--10000	CustomerA	0x4BC24533B493337403CCA2DF6B4E5885D1E531925CFF3C238C3DBC52274ADA0B10ACB22C591DE7A0A8FD5F528CE35C6608F9C17B67352BA7E7D302F1F9ACD651E9AA5B52275D005BB0D2C672A76888CEF3B29D12C49A2DD5B8A5A7CAD96F76A24E4EDEBF070E878DB7CA9CDFE9D6B9CC36AF8710125EB29DC7253FCBD44983EDF13E56C5B27EE54798BCE239D315DC67F31FDE01B99907CF419A657F7F8E2AE66E6350FF8DF9C6EA8DD94C05002B400B6A0BFF6E4B26552A3ADDFE440BAE7B9C03AD0BA61854CB35F3EC8F785A0C1E8088152695BDF3C4157AF4B6D129ECC6594D1AE1948615CEA6F9D47DCF1BE20B1956AF2109F95B68256534A9BC2B159A5D	13402872514
--10001	CustomerB	0x9AC581BF0EFB18280C1497F1C02A46C2AF7C37912709A7F564B81FFBF499EDB000A384477815A5D37AEFAB863D7141967727AA4B5B10D37C4ADB957572A5FA512999D314CD09336493F59872CA2D746CC282524B29AC725247D6C8CB56B5AD8C7E6FEAC701946E65E18E507E50C6B577E954ED6A8544A6C2DC7457AEDE3BCDD37FC33C7975FDB570D9F293E77825B1E4B05320D96E0D62954D08BB2E16CC726CD280139DA5592D3DF835C01F83823ECED6C3D7DF2D5E7E12AA493850CE0EC0BA464B1621B413FCF2E9C4BA0C5710CC8ECFAFC8DE0C1F047CB730E0B91744AA252E913EDD0D25DBA6F854ED5946CE45A544EE1EA146D3E65DB3D9F249EA14CBA9	13880674722
--10002	CustomerC	0x57ED91B64D532CA3E8F21759339E05F11674BCF6BBD627A00C276187172BF2A43EC1777007A0C04130D1C7F014DE06927090A3590148BAE3D0332DCBFBACC6E49EBC6CD0D3E197A0EA7F7EDC9363C6E41DDA3BEAA08EEE995BFCF74D1B959480118CFCC5BA55EE681104023EDBAE4F3A69800780ACD01FD5117A4542988510280B2B3C522436828D48A14D93F8051C1564B7A3628BAF589B102A89DBC45E0544CD4D593EC1B37F4222AFBC90C33D571BB930F3FB30DEF485DB129923F54E4533042E2EAB9EAC24D768DDD99CFF32E8F51AD6107BDDC8CD1303DB84524C0D7C59E51740946ED90980CA20C2B4C6BE2917B09B03FB625F4554587664A947FB1290	13487759293
--10003	CustomerD	0x33E3569D2BE64BB7F354345CF62A971A3450B86C26790A1D50A64C1DB2949114C22386CCD9B7680A5E63DA92D7E91F9D217ED87B82923E167B0BAEBDC718BCA6167182D311F1AE172B922E03CB727A72AFAA02A4788280C28C668F5498F9C1180147380149149F0777D36845EC9C23A08775645E9F043A81A2D375C5E5C1EB2626F67D3DAC82A1E2042D556B2D76AE1EC429510DCBC643D682D53201D828F58B8462696FDC528D877FC22F559E809CED744E8058B929B6AD7ABFE8F8963C09ED78F6E06A47E8D3B40A7F29A2793C08ECCC06DC3651E98BF8E05C63A566FE32FDA8F55928E66072A62C4B1D5F775A2DD7DCBD4EC140D3B8196AEEB32A0C68B016	13880971234

-- volvemos al usuario original
REVERT
GO

SELECT SYSTEM_USER
GO




