select * 
from SQLProject..NashvilleHouse

--standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From SQLProject..NashvilleHouse

Update NashvilleHouse
Set SaleDate = CONVERT(Date, SaleDate)





--Populate Property Address Data

Select PropertyAddress
From SQLProject..NashvilleHouse
Where PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLProject..NashvilleHouse a
JOIN SQLProject..NashvilleHouse b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLProject..NashvilleHouse a
JOIN SQLProject..NashvilleHouse b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null





--Breaking Address into Seperate columns (Address, City, State)
Select PropertyAddress
From SQLProject..NashvilleHouse
--Where PropertyAddress is null

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From SQLProject..NashvilleHouse

--Execute single by single
Alter Table NashvilleHouse
Add PropertySplitAdd Nvarchar(255);

Update NashvilleHouse
Set PropertySplitAdd = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHouse
Add PropertySplitCityy Nvarchar(255);

Update NashvilleHouse
Set PropertySplitCityy = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * 
From SQLProject..NashvilleHouse


--Seperating Owners name with using Parse name

select OwnerAddress
From SQLProject..NashvilleHouse

select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME(Replace(OwnerAddress, ',' , '.') , 2)
,PARSENAME(Replace(OwnerAddress, ',' , '.') , 1)
From SQLProject..NashvilleHouse

Alter Table NashvilleHouse
Add OwnerAdd Nvarchar(255);

Update NashvilleHouse
Set OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

Alter Table NashvilleHouse
Add OwnerCity Nvarchar(255);

Update NashvilleHouse
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

Alter Table NashvilleHouse
Add OwnerState Nvarchar(255);

Update NashvilleHouse
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)

Select *
From SQLProject..NashvilleHouse



--Chnage Y & N to yes and No in "Soold as vacant" field

Select Distinct(SoldAsVacant) --to check variety of data in column
From SQLProject..NashvilleHouse

Select Distinct(SoldAsVacant), Count(SoldAsVacant) --to check variety of data count
From SQLProject..NashvilleHouse
Group by SoldAsVacant

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From SQLProject..NashvilleHouse

Update NashvilleHouse
SET SoldAsVacant =  CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END


--Remove duplicates (rows)

--1.By writing CTE
--this will show duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From SQLProject.dbo.NashvilleHouse
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--To Dlete Duplicates 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From SQLProject.dbo.NashvilleHouse
)
Delete
From RowNumCTE
Where row_num > 1



--DElete Unused columns.

SELECT * 
From SQLProject.dbo.NashvilleHouse

ALTER TABLE SQLProject.dbo.NashvilleHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE SQLProject.dbo.NashvilleHouse
DROP COLUMN SaleDate
