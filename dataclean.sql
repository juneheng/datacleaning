-- Clean Data with Sql Project

-----------------------------------------------------------------------
------how does the data look like

Select Top (5) *
From PorfolioProject..NashivilleHousing

------------------------------------------------------------------------
-- standardie data format
select SaleDateConverted, CONVERT(Date, SaleDate)
From PorfolioProject..NashivilleHousing

Alter Table NashivilleHousing
Add SaleDateConverted Date

Update NashivilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

--populate the property address
-- If two rows have the same ParcelID, but one is with PropertyAddress, the other one is Null.
-- We use self-join to change the null to value with the same ParcelID.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PorfolioProject..NashivilleHousing as a
Join PorfolioProject..NashivilleHousing as b
On a.ParcelID = b.ParcelID and a.[UniqueID ] <>b.[UniqueID ]

Where a.PropertyAddress is null

Update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PorfolioProject..NashivilleHousing as a
Join PorfolioProject..NashivilleHousing as b
On a.ParcelID = b.ParcelID and a.[UniqueID ] <>b.[UniqueID ]
Where a.PropertyAddress is null

Select *
From PorfolioProject..NashivilleHousing
--where PropertyAddress is null

---delete the duplicate
---if the propertyAddress, saledate, saleprice, legalrefernce are the same, we claim the transactions
---are same, so we delete the duplicate ones to make value distinct.
---we use row_number()fuction to get the rank and delete the ranking number are over 1.

With cte AS 
(
Select *, ROW_NUMBER() OVER(
	Partition by
				ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
			Order by UniqueID
			) as row_num
From NashivilleHousing
)
Select *
From cte
Where row_num =1

---change string. the column 'SoldAsVacant' there are 399 N and 52 Y.
---we need to change N to No, and Y to YES.

Select count(SoldAsVacant), SoldAsVacant
From PorfolioProject..NashivilleHousing
group by SoldAsVacant

Update PorfolioProject..NashivilleHousing
Set SoldAsVacant =
		Case When SoldAsVacant = 'Y' THEN 'Yes'
			 When SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
From PorfolioProject..NashivilleHousing

Select SoldAsVacant, count(SoldAsVacant)
From NashivilleHousing
Group by SoldAsVacant

----drop column from table
Select *
From NashivilleHousing

ALTER TABLE NashivilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

---- substring---
---use substring function to divide address into 'street address' and 'state'
---unfortunely the address column has been deleted from last step.
---I will use other example to practice this function.