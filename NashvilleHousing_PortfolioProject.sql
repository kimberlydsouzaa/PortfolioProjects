--Populating the property address
SELECT *
FROM nashville_housing
ORDER BY parcelid

SELECT A.uniqueid, A.parcelid, A.propertyaddress, B.uniqueid, B.parcelid, B.propertyaddress, COALESCE(A.propertyaddress, B.propertyaddress)
FROM nashville_housing A
JOIN nashville_housing B
	ON A.parcelid = B.parcelid
	AND A.uniqueid <> B.uniqueid
WHERE A.propertyaddress IS NULL;

UPDATE nashville_housing
SET propertyaddress = COALESCE(nashville_housing.propertyaddress, B.propertyaddress)
FROM nashville_housing B
WHERE nashville_housing.propertyaddress IS NULL
	AND nashville_housing.parcelid = B.parcelid
	AND nashville_housing.uniqueid <> B.uniqueid

--Breaking out address into individual columns (address, city, state)
--(this is one way of doing it)
SELECT propertyaddress
FROM nashville_housing

SELECT SUBSTRING(propertyaddress,1,STRPOS(propertyaddress, ',') -1) AS propertysplit_address,
	SUBSTRING(propertyaddress,STRPOS(propertyaddress, ',') +1) AS propertysplit_city
FROM nashville_housing

ALTER TABLE nashville_housing
ADD propertysplit_address VARCHAR(300)

UPDATE nashville_housing
SET propertysplit_address = SUBSTRING(propertyaddress,1,STRPOS(propertyaddress, ',') -1)

ALTER TABLE nashville_housing
ADD propertysplit_city VARCHAR(300)

UPDATE nashville_housing
SET propertysplit_city = SUBSTRING(propertyaddress,STRPOS(propertyaddress, ',') +1)

--(this is another way of splitting into separate column)
SELECT SPLIT_PART(owneraddress, ',', 1) AS ownersplit_address,
	SPLIT_PART(owneraddress, ',', 2) AS ownersplit_city,
	SPLIT_PART(owneraddress, ',', 3) AS ownersplit_state
FROM nashville_housing

ALTER TABLE nashville_housing
ADD ownersplit_address VARCHAR(300)

UPDATE nashville_housing
SET ownersplit_address = SPLIT_PART(owneraddress, ',', 1)

ALTER TABLE nashville_housing
ADD ownersplit_city VARCHAR(300)

UPDATE nashville_housing
SET ownersplit_city = SPLIT_PART(owneraddress, ',', 2)

ALTER TABLE nashville_housing
ADD ownersplit_state VARCHAR(300)

UPDATE nashville_housing
SET ownersplit_state = SPLIT_PART(owneraddress, ',', 3)

--Changing Y and N to Yes and No in 'Sold as vacant' column
SELECT DISTINCT soldasvacant, COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY COUNT(soldasvacant)

SELECT soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
	END
FROM nashville_housing

UPDATE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
						WHEN soldasvacant = 'N' THEN 'No'
						ELSE soldasvacant
					END

--Removing Duplicates
WITH CTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
	ORDER BY uniqueid ) AS row_num
FROM nashville_housing
--ORDER BY parcelid
)
SELECT *
FROM CTE
WHERE row_num > 1

WITH CTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
	ORDER BY uniqueid ) AS row_num
FROM nashville_housing
--ORDER BY parcelid
)
DELETE FROM nashville_housing
WHERE uniqueid IN (SELECT uniqueid FROM CTE WHERE row_num > 1)

--Deleting unused columns
ALTER TABLE nashville_housing
DROP COLUMN saledate,
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict

SELECT *
FROM nashville_housing