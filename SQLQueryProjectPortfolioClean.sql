
Select *
From PortfolioProject..NashvillHousing

Select SalesDateConverted,Convert(date,SaleDate) 
From PortfolioProject..NashvillHousing

Update NashvillHousing
Set SaleDate = Convert(date,SaleDate)

-- Standardize date format

Alter Table NashvillHousing
Add SalesDateConverted Date;

Update NashvillHousing
Set SalesDateConverted = Convert(date,SaleDate)

--Populate Property Address data

Select PropertyAddress
From NashvillHousing

Select propA.ParcelID, propA.PropertyAddress, propB.ParcelID, propB.PropertyAddress, 
isnull(propA.PropertyAddress, propA.PropertyAddress)
From PortfolioProject..NashvillHousing as propA
Inner Join PortfolioProject..NashvillHousing as propB
    on propA.ParcelID = propB.ParcelID
	and propA.[UniqueID ] <> propB.[UniqueID ]
Where propA.PropertyAddress is null

Update propA
Set PropertyAddress = isnull(propA.PropertyAddress, propA.PropertyAddress)
From PortfolioProject..NashvillHousing as propA
Inner Join PortfolioProject..NashvillHousing as propB
    on propA.ParcelID = propB.ParcelID
	and propA.[UniqueID ] <> propB.[UniqueID ]
Where propA.PropertyAddress is null

--Breaking the property Address into (Address, city)

Select PropertyAddress
From NashvillHousing

Alter Table NashvillHousing 
Add PropertySplitAddress nvarchar(225);

Update NashvillHousing
Set PropertySplitAddress = Substring(PropertyAddress,1, Charindex(',', PropertyAddress) -1)

Alter Table NashvillHousing 
Add PropertySplitCity nvarchar(225);

Update NashvillHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',',PropertyAddress) +1, len(PropertyAddress))

--Breaking the Owner Address into (Address, city and state)

Select OwnerAddress
From NashvillHousing

Select
Parsename(Replace(OwnerAddress, ',','.'), 3)
,Parsename(Replace(OwnerAddress, ',','.'), 2)
,Parsename(Replace(OwnerAddress, ',','.'), 1)
From PortfolioProject..NashvillHousing

Alter Table NashvillHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvillHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',','.'), 3)

Alter Table NashvillHousing
Add OwnerSplitCity nvarchar(255);

Update NashvillHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',','.'), 2)

Alter Table NashvillHousing
Add OwnerSplitState nvarchar(255);

Update NashvillHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',','.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject..NashvillHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then  'No'
	 Else SoldAsVacant
     End
From PortfolioProject..NashvillHousing

update NashvillHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then  'No'
	 Else SoldAsVacant
     End



--Remove Duplicate

With RowNumCTE as (

Select *,
Row_number() Over (Partition by ParcelID,
                                PropertyAddress,
								SaleDate,
								LegalReference,
								OwnerAddress
					 Order by 
					 UniqueID
					 ) as row_num

From PortfolioProject..NashvillHousing
)

Select *
From RowNumCTE
Where row_num>1

--Delete unsued columns

Select *
From PortfolioProject..NashvillHousing

Alter Table PortfolioProject..NashvillHousing
Drop column OwnerAddress,TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvillHousing
Drop column SaleDate
