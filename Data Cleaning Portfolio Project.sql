--PROJECT --- Cleaning data in sql queries
--Clean data and make it more useful
--Since we have deleted some columns in the end, so some scripts will not work as those columns
--we used are no longer there.

select *
from PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------

--Standardize sale date format / date format

select SaleDate, convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

select SaleDate, SaleDateConverted
from PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------

--populate property address data

select *
from PortfolioProject..NashvilleHousing

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--parcel id is same for many.
--so we will use parcel id to populate nulls in property address
--we checked above and now we will populate table by joining the table to it self

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) -- check to see if first is null, then populate with second
from PortfolioProject..NashvilleHousing a                                                                         -- i.e. if a is null, populate with value that is in b
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]  -- <> means is not equal
where a.PropertyAddress is null

update a   -- when we use joins in update statement, we dont use table name as it will give error. We use alias.
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
-----------------------------------------------------------------------------

--breaking out address into individual columns (address, city, state)
--PROPERTY ADDRESS
select PropertyAddress
from PortfolioProject..NashvilleHousing

select substring (PropertyAddress,1,3) --start from 1st value and show till 3rd value
from PortfolioProject..NashvilleHousing

--first we will separate till comma
--comma here is called delimeter
--a delimeter separates values or columns

select substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
--character index searches for specific value
--here we are searching for comma so we used comma
from PortfolioProject..NashvilleHousing

--character index is actually numerical
--see below code
select substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)),CHARINDEX(',', PropertyAddress)  
from PortfolioProject..NashvilleHousing

--as we are getting comma in address, we need to remove it.
--we remove by subtracting 1 from charindex value

select substring (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address --character index searches for specific value
from PortfolioProject..NashvilleHousing

--CITY
select PropertyAddress, substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)) as City --go from comma to end of address using LENgth
from PortfolioProject..NashvilleHousing

--above we are also getting comma at start of city
select PropertyAddress, substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City --go from comma to end of address using LENgth
from PortfolioProject..NashvilleHousing

--minus 1: go till comma then minus 1 value from end so comma will be removed
--plus 1: we start from comma for city. plus 1 so we start one value after. so comma will be removed from start


--now we need to create to new columns to add the address as address and city separately

--column1
alter table NashvilleHousing  
add separatedAddress nvarchar(255)

update NashvilleHousing
set separatedAddress = substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--column2
alter table NashvilleHousing  
add separatedCity nvarchar(255)

update NashvilleHousing
set separatedCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-----------------------------------------------------------

--OWNER ADDRESS
--now we will use another method for separating address
--parsename...much easier than substring
--parsename is used with period (.) so we will replace comma with period, Then we can use it

select OwnerAddress
from PortfolioProject..NashvilleHousing

select parsename (OwnerAddress,1)  --this separates values by periods. But as there are no periods but commas, so it will not work here.
from PortfolioProject..NashvilleHousing

--so now we will replace comma with periods
select parsename (replace (OwnerAddress, ',', '.') , 1), -- now this is showing only TN i.e. showing from end...(588  HUNTINGTON PKWY, NASHVILLE, TN)
	parsename (replace (OwnerAddress, ',', '.') , 2), -- this is showing middle value i.e. NASHVILLE
	parsename (replace (OwnerAddress, ',', '.') , 3) -- this is showing first value i.e. 588  HUNTINGTON PKWY
from PortfolioProject..NashvilleHousing

--so now we got all values separated by in reverse order i.e. from 3rd to 1st.
-- now we will make them in proper order i.e. from 1st to 3rd by writing numbers in reverse order.

select parsename (replace (OwnerAddress, ',', '.') , 3), -- now this is showing only 588  HUNTINGTON PKWY i.e. showing from end...(588  HUNTINGTON PKWY, NASHVILLE, TN)
	parsename (replace (OwnerAddress, ',', '.') , 2), -- this is showing middle value i.e. NASHVILLE
	parsename (replace (OwnerAddress, ',', '.') , 1) -- this is showing first value i.e. TN
from PortfolioProject..NashvilleHousing

--now create three new columns to put these values separetly

alter table NashvilleHousing
add separatedOwnerAddress nvarchar (255)

update NashvilleHousing
set separatedOwnerAddress = parsename (replace (OwnerAddress, ',', '.') , 3)

alter table NashvilleHousing
add separatedOwnerCity nvarchar (255)

update NashvilleHousing
set separatedOwnerCity = parsename (replace (OwnerAddress, ',', '.') , 2)

alter table NashvilleHousing
add separatedOwnerState nvarchar (255)

update NashvilleHousing
set separatedOwnerState = parsename (replace (OwnerAddress, ',', '.') , 1)

-----------------------------------------------

--Change Y and N to Yes and No in 'Sold As Vacant' field
--here we will use case statement
--we can also use simple method of update and set but we have to do it one by one. 
--so if there are many values to be updated, case statement is best to use

select Distinct (SoldAsVacant), COUNT (soldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

--here use update to change Y to Yes

select SoldAsVacant
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'  --done..worked

--here use case method
select SoldAsVacant,
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

--now update table
update NashvilleHousing
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
---------------------------------------------------
--Remove Duplicates -- dont do this with raw data -- not recommended

-- we will remove duplicates by using window function i.e. row_number
-- row_number will assign values to each unique row
-- for unique data it will assign 1, 1, 1, so on if we specify what columns to look into
-- if two rows have same/ duplicate data in columns that we specify to look into, then it will assign 1 then 2 then 3 and so on, to show duplicates
-- so from this we can tell that such rows have same data and we can easily remove such duplicate rows
-- row_number, rank, dense_rank always use OVER(PARTITION BY) 

select *,
ROW_NUMBER () over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
					order by UniqueID) as rownum
from NashvilleHousing

------------------------------------------------------------------------------
-- putting above code here

select *  --using subquery here...query inside query
from

(select *,
ROW_NUMBER () over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
					order by UniqueID) as rownum
from NashvilleHousing) as x

where rownum > 1
order by PropertyAddress

--------------------------------------------------
select * 
from x    --we cannot use this, it gives error. so we will use CTE instead of subquery.

--CTE
with rownumberCTE as
(
select *,
ROW_NUMBER () over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
					order by UniqueID) as rownum
from NashvilleHousing
)

select *
from rownumberCTE  --now we can select this above code easily
where rownum >1

-- to delete these duplicate rows, we will use delete and select whole code including ctes
-- here i am copying the cte code again and then use delete

--CTE
with rownumberCTE as
(
select *,
ROW_NUMBER () over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
					order by UniqueID) as rownum
from NashvilleHousing
)

delete          -- delete
from rownumberCTE  --now we can select this above code easily
where rownum >1

-----------------------------------------------------

-- Delete unused columns -- dont do this with raw data -- not recommended

select *
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress

alter table NashvilleHousing
drop column SaleDate
-----------------------------------------------------
select *
from PortfolioProject..NashvilleHousing