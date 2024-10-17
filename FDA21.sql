use fda21;
##Task - 1
## 1.1 Determine the numer of drugs approved each year and provide insights into the yearly trends.
SELECT COUNT(p.drugname) AS AppDrugs, YEAR(r.ActionDate) AS Year
FROM Product AS p INNER JOIN RegActionDate AS r
ON p.ApplNo = r.ApplNo
WHERE r.ActionType = "AP" GROUP BY YEAR(r.ActionDate) ORDER BY YEAR(r.ActionDate) ASC; 


## 1.2 identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively.
## --- Top 3 Years with highest approvals (in descending order)
SELECT COUNT(p.drugname) AS AppDrugs, YEAR(a.DocDate) AS Year
FROM Product AS p INNER JOIN AppDoc AS a
ON p.ApplNo = a.ApplNo
WHERE a.ActionType = "AP" GROUP BY YEAR(a.DocDate) ORDER BY YEAR(a.DocDate) DESC LIMIT 3;

## ---- 3 Years with lowest approvals (ascending order) 
SELECT COUNT(p.drugname) AS AppDrugs, YEAR(a.DocDate) AS Year
FROM Product AS p INNER JOIN AppDoc AS a
ON p.ApplNo = a.ApplNo
WHERE a.ActionType = "AP" GROUP BY YEAR(a.DocDate) ORDER BY YEAR(a.DocDate) ASC LIMIT 3;


## 1.3 Explore approval trends over the years based on sponsors.
SELECT a.SponsorApplicant, r.ActionType,  YEAR(r.ActionDate)
/*(CASE WHEN r.ActionType = "AP" THEN "APPROVED" WHEN r.ActionType = "TA" THEN "In Progress" ELSE "NA" END) AS "Approval_Status"*/
FROM Application AS a INNER JOIN RegActionDate AS r ON a.ApplNo = r.ApplNo 
GROUP BY 1,2,3 ORDER BY Year(r.ActionDate) ASC; 

## 1.4 Rank sponsors based on the total number of approvals they received every year between 1939 and 1960

SELECT a.SponsorApplicant, a.ActionType, YEAR(ad.DocDate),
RANK() OVER (PARTITION BY a.ActionType ORDER BY YEAR(ad.DocDate)) AS "Rank"
FROM Application AS a INNER JOIN AppDoc AS ad ON a.ApplNo = ad.ApplNo
WHERE YEAR(ad.DocDate) BETWEEN 1939 AND 1960 AND a.ActionType = "AP" GROUP BY 1,2,3;

## Task - 2
## 2.1 Group products based on MarketingStatus.Provide meaningful insights into the segmentation patterns.

SELECT p.ProductMktStatus, a.ApplType, a.SponsorApplicant, a.ActionType, COUNT(p.ProductNo)
FROM Product AS p INNER JOIN Application AS a ON p.ApplNo = a.ApplNo GROUP BY 1,2,3,4;

## 2.2 Calculate the total number of applications for each MarketingStatus Year-wise after the year 2010.
SELECT  p.ProductMktStatus, YEAR(ad.DocDate), COUNT(ad.ApplNo)
FROM AppDoc AS ad LEFT JOIN Product AS p 
ON ad.ApplNo =  p.ApplNo
WHERE YEAR(ad.DocDate) >= 2010
GROUP BY 1,2 ORDER BY YEAR(ad.DocDate);

## 2.3 Identify the top MarketingStatus with the maximum number of applications and analyze its trends over time.
SELECT YEAR(ad.DocDate), COUNT(p.ProductMktStatus)
FROM appdoc AS ad LEFT JOIN product AS p ON ad.ApplNo = p.ApplNo
WHERE p.ProductMktStatus = 1 GROUP BY 1 ORDER BY YEAR(ad.DocDate) ASC;

## Task - 3
## 3.1 Categorize Products by dosage form and analyze their distribution
SELECT DISTINCT Dosage, ProductNo, Form,
PERCENT_RANK() OVER(PARTITION BY FORM ORDER BY Dosage DESC) AS "P%Rank"
FROM Product;

## 3.2 Calculate the total number of approvals for each dosage form and identify the most successful forms

## -------- Dosage for each form
SELECT p.Dosage, COUNT(ad.ActionType)
FROM AppDoc AS ad LEFT JOIN Product AS p
ON p.ApplNo = ad.ApplNo
WHERE ad.ActionType = "AP"
GROUP BY p.Dosage;

## ------ Total number of approvals- for each dosage form

SELECT p.Form, ra.ActionType, CEIL(DATEDIFF(NOW(), ra.ActionDate)/365) AS "TotalAge",
(CASE WHEN CEIL(DATEDIFF(NOW(), ra.ActionDate)/365) > 50 THEN "MostSuccessfull" 
WHEN CEIL(DATEDIFF(NOW(), ra.ActionDate)/365) > 30 THEN "Successfull" 
WHEN CEIL(DATEDIFF(NOW(), ra.ActionDate)/365) < 30 THEN "LeastSuccessful" ELSE "NA" END) AS "DOSAGEFORM"
FROM RegActionDate AS ra LEFT JOIN product AS p
ON p.ApplNo = ra.ApplNo
WHERE ra.ActionType = "AP"
ORDER BY DOSAGEFORM DESC;


## 3.3 Investigate yearly trends related to successful forms.
SELECT YEAR(Actiondate), COUNT((CEIL(DATEDIFF(NOW(), ActionDate)/365))) AS "DosageForm",
(CASE WHEN CEIL(DATEDIFF(NOW(), ActionDate)/365) > 50 THEN "MostSuccessfull" 
WHEN CEIL(DATEDIFF(NOW(), ActionDate)/365) > 30 THEN "Successfull" 
WHEN CEIL(DATEDIFF(NOW(), ActionDate)/365) < 30 THEN "Least_Successfull" ELSE "NA" END) AS Form_category
FROM RegActionDate
WHERE ActionType = "AP"
GROUP BY 1,3
ORDER BY DosageForm;


## Task - 4
## 4.1 Analyze edrug approvals based on therapeutic evaluation code (TE_Code).
SELECT pte.TECode, YEAR(ra.ActionDate), ra.ActionType, pte.ProductMktStatus, COUNT(p.drugname) 
FROM Product AS p INNER JOIN RegActionDate AS ra INNER JOIN Product_TECode AS pte
ON p.ApplNo = ra.ApplNo
AND ra.ApplNo = pte.ApplNo
/*WHERE ra.ActionType = "AP"*/
GROUP BY ra.ActionType, YEAR(ra.ActionDate), pte.TECode, pte.ProductMktStatus
ORDER BY YEAR(ra.ActionDate);

## 4.2 Determine the therapeutic evaluation code (TE_Code) with the highest number of Approval each year.
SELECT YEAR(ra.ActionDate), pte.TECode, COUNT(ra.ActionType)
FROM RegActionDate AS ra INNER JOIN Product_TECode AS pte
ON ra.ApplNo = pte.ApplNo
WHERE ra.ActionType = "AP" GROUP BY pte.TECode, YEAR(ra.ActionDate) ORDER BY COUNT(ra.ActionType) DESC;
 

