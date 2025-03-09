--Cleaning Data with SQL Queries


--Populate Property Address data

Select *
From HousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingProject.dbo.NashvilleHousing a
Join HousingProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From HousingProject.dbo.NashvilleHousing a
Join HousingProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------

--Breaking out Property Address into individual columns (address, city, state)

Select PropertyAddress
From HousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From HousingProject.dbo.NashvilleHousing


Alter Table HousingProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update HousingProject.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


Alter Table HousingProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update HousingProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


------------------------------------------------------------------------------------------

--Breaking out Owner Address into separate columns (address, city, state)


Select OwnerAddress
From HousingProject.dbo.NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress, ',', '.'),3)
,PARSENAME(Replace(OwnerAddress, ',', '.'),2)
,PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From HousingProject.dbo.NashvilleHousing


Alter Table HousingProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update HousingProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)


Alter Table HousingProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update HousingProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

Alter Table HousingProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update HousingProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)


------------------------------------------------------------------------------------------

--Change 1 and 0 to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Alter Table HousingProject.dbo.NashvilleHousing
Alter Column SoldAsVacant Nvarchar(255);


Select SoldAsVacant
, Case When SoldAsVacant = '1' THEN 'Yes'
       When SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END
From HousingProject.dbo.NashvilleHousing


Update HousingProject.dbo.NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = '1' THEN 'Yes'
       When SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates

WITH RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num


From HousingProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

------------------------------------------------------------------------------------------

--Delete Unused Columns


Select *
From HousingProject.dbo.NashvilleHousing

Alter Table HousingProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

