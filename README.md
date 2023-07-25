# ML Model for Prediction of Regional Housing Needs Assessment in Southern California

## Introduction
Having an affordable and livable dwelling is one of the essential needs in everybody’s life.
Beginning in 1969, it’s required by California law[1] that every local government (city and county)
has a plan and periodical evaluation[2] to ensure that the number of housing fulfills each community’s
need[3]. To make sure that State and local governments can coordinate well on the implement the plan,
a process called the regional housing needs assessment (RHNA) has been implemented[3]. The strategy
works as the following: the California Department of Housing and Community Development (HCD)
first calculates the regional housing need for each local government, using a formula based on
demographic population information provided by California Department of Finance[3]. Local
governments then include the local factors, which may not be considered in the HCD’s calculation, and
generate new numbers that fit local needs based on HCD’s calculation[3].

In southern California, six counties (Imperial, Los Angeles, Orange, Riverside, San Bernardino
and Ventura) work together as Southern California Association of Governments (SCAG) to coordinate
with State government during the RHNA process[2]. Publicly accessible data is available at SCAG’s
website[2], which reflects how the six counties work as a whole to reflect the forecast of local needs
between 2030 and 2045. From the data of spreadsheets[2], one is able to know what factors are taken
into account during the decision process, such as 2030-2045 household growth from SCAG's 2020
RTP/SCS (HHGR_30_45), Percent owner households, ACS 2013-2017 (PCT_OWN), percent of each
income bracket (very low income, low income, moderate income, above moderate income),
Jurisdiction's share of regional population using CA DOF 1/1/2019 data (PCT_POP19). One can also
infer how the need of RHNA is calculated from the formula in the spreadsheet. However, there is no
explicit explanation how the formula is determined nor how the coefficients in the calculation[2] were
determined. Similar issue is found in HCD’s number.

Therefore, there is a need of a simpler and more straightforward model for easier understand
and inference of the data. This report is trying to apply various machine learning (ML) models to the
available data set, and provide a simpler formulation of the problem.

## Machine Learning Models
  The nature of this problem is a supervised regression problem, so the following regression
models are picked for this report.
• Lasso Model   
• Regression Tree (plus random forests)    
• Principal Component Regression (PCR)   
• Linear Regression (plus Best Subset Selection)   
• Generalized Additive Model (GAM)   
  For each model, the same randomly-selected data set, which contains 4/5 of total data points, are used
as training set while the rest serves as the test set. The test set is used for computing test mean squared
error (MSE).

## Result
**Correlation Pairs**
![image](https://user-images.githubusercontent.com/30448897/116798263-ac798100-aaa2-11eb-9bff-60f082ef1aad.png)

**Trend of coefficients with lambda in the lasso model**
![lasso_feature_selection](https://user-images.githubusercontent.com/30448897/116798238-6ae8d600-aaa2-11eb-928e-d1ee5596eaff.png)

**Regression Tree of RHNA**
![regression_tree_original](https://user-images.githubusercontent.com/30448897/116798240-7a681f00-aaa2-11eb-88b1-5f9e86262c0a.png)

**Best Subset Selection by Comparing Error**
![subset_error_comparison](https://user-images.githubusercontent.com/30448897/116798242-83f18700-aaa2-11eb-8eca-33e68adf2a78.png)

**Cross-validation between the numbers of component in PCR**
![pcrMSEP](https://user-images.githubusercontent.com/30448897/116798245-8c49c200-aaa2-11eb-995e-1f670853e91c.png)

**Fitting Results of the Features in GAM**
![gamFitting_orig](https://user-images.githubusercontent.com/30448897/116798246-8fdd4900-aaa2-11eb-9e36-65e64d09b68a.png)


## Conclusion
  From the test MSE listed in the table below, one can see that GAM has the best performance,
followed by multiple linear regression (using the features selected by best subset selection). The
models of regression trees don’t perform as well as other regression models, as the earlier paragraph
mentioned. Judging from the training and test MSE in the table shown below, I would think GAM is
the most suitable model for this problem, especially due to its low test MSE[4].

|Algorithms/Models|Training MSE|Calculated Test MSE|
|-----------------|-----------:|------------------:|
|lasso|3.14e6|4.46e6|
|Regression Tree|3.13e7|4.48e7|
|Random Forests|4.93e6|1.95e7|
|Principal Components Regression (PCR)| 3.15e6| 3.69e6 (17 components)|
|Multiple Linear Regression|2.91e6|2.39e6|
|Generalized Additive Model (GAM)|6.56e5|1.72e6|

### Reference
[1] “HCD State Housing Law Program Laws and Regulations.” https://hcd.ca.gov/building-standards/state-housing-law/state-housing-laws-regulations.shtml   
[2] “Regional Housing Needs Assessment,” Southern California Association of Governments. https://scag.ca.gov/rhna.   
[3] “HCD Regional Housing Needs Allocation and Housing Elements.” https://www.hcd.ca.gov/community-development/housing-element/index.shtml.   
[4] G. James, D. Witten, T. Hastie, and R. Tibshirani, An Introduction to Statistical Learning: with
Applications in R. Springer New York, 2013.   
