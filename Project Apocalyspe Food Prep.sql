-- Display all data
SELECT *
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing


-------------------------------------------------------------------------------------------------------------

--Standadize Date format
SELECT SaleDate, SaleDAte_Converted
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate) --Not working, don't know why?

	--Creating new column
ALTER TABLE NashvilleHousing
ADD SaleDate_Converted DATE

	-- Upating new date format to new column
UPDATE NashvilleHousing
SET SaleDate_Converted = CONVERT(DATE,SaleDate)

	-- Delete old SaleDate column
ALTER TABLE	NashvilleHousing
DROP COLUMN SaleDate


-------------------------------------------------------------------------------------------------------------

-- Populating PropetyAddress data

	/* Checking if we have NULL values in PropetyAddress and 
	then replace NULL values with specific values in new column*/
SELECT 
	a.ParcelID, a.[UniqueID ], a.PropertyAddress, b.[UniqueID ], b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) AS Null_Property_Adress_Replaced
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing a
JOIN [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

	-- Replacing NULL values with specific values in Property Address column using UPDATE
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing a
JOIN [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------------------

/* Breaking out PropertyAddress into individual columns (Address, City, State)
Splited Address and Splited City are much more usable than the merged version of them */

SELECT 
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing

	-- Creating Property_Split_Address column and adding Splited Address
ALTER TABLE NashvilleHousing
ADD Property_Split_Address nvarchar(255)

UPDATE NashvilleHousing
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

	-- Creating Property_Split_City column and adding Splited City
ALTER TABLE NashvilleHousing
ADD Property_Split_City nvarchar(255)

UPDATE NashvilleHousing
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-------------------------------------------------------------------------------------------------------------

-- Breaking out OwnerAddress into individual columns (Address, City, State)

	-- Using PARSENAME to split out OwnerAddress (PARSENAME separate everything for us but it’s backward)
SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing

	-- Creating Owner_Split_Address column and adding Splited Address
ALTER TABLE NashvilleHousing
ADD Owner_Split_Address nvarchar(255)

UPDATE NashvilleHousing
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

	-- Creating Owner_Split_City column and adding Splited City
ALTER TABLE NashvilleHousing
ADD Owner_Split_City nvarchar(255)

UPDATE NashvilleHousing
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

	-- Creating Owner_Split_State column and adding Splited State
ALTER TABLE NashvilleHousing
ADD Owner_Split_State nvarchar(255)

UPDATE NashvilleHousing
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold As Vacant' field

	-- See if we have Y, N in SoldAsVacant column
SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(SoldAsVacant)
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2 
	-- Changing Y to Yes and N to No
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END AS SoldAsVacantFixed
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

-------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

	/* Using ROW_NUMBER and PARTITION BY to rank value based on these partitions: 
	ParcelID, SalePrice, PropertyAddress, LegalReference, SaleDate_Converted.
	If all values in each partition are the same, those values will be ranked as 1, 2, 3,.. respectively.
	Then we will delete the values which are ranked as 2, 3...*/

WITH Row_Num_CTE AS 
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, SalePrice, PropertyAddress, LegalReference, SaleDate_Converted
	ORDER BY UniqueID) row_num
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing
)

SELECT * 
FROM Row_Num_CTE
WHERE row_num > 1

	-- Delete duplicated rows
WITH Row_Num_CTE AS 
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, SalePrice, PropertyAddress, LegalReference, SaleDate_Converted
	ORDER BY UniqueID) row_num
FROM [Porfolio Project - Apocalyspe Food Prep]..NashvilleHousing
)

DELETE 
FROM Row_Num_CTE
WHERE row_num > 1


-------------------------------------------------------------------------------------------------------------

-- Delete unused column

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict