**************************************************************************************************************
                     *TASK 3: American Community Survey Sample
**************************************************************************************************************
**Import Dataset
clear 
set moreoff
use "C:\Users\22031\Desktop\Econometrics do files\Task 3\American Community Survey Sample.dta"
*Recode employment indicating 1 as Armed force at work and Zero(0) as civilian employed at work
recode esr (4=1) (1=0), gen(employment_status)
* Generate a dummy variable for sex
gen female=(sex>1)
*Interact between usual hour worked per week and sex
gen wkhp_female=wkhp*female
*Generate age square to capture the increasing or diminising effect of age on hourly wages or salaries
gen agesquare=agep^2
*Generate log of WHOUR
gen log_whour=log(whour)
****************************************************************************************
*Ordinary Least Squares 
****************************************************************************************
*Run a regression and include the adoc command to export the results to word document*
asdoc reg log_whour female agep agesquare  wkhp wkwn wkhp_female i.mar i.schl employment_status, save(wincome1) dec(5)


****************************************************************************************
*Lasso regression Model
****************************************************************************************
*Group Categorical variables and continuous
vl set, categorical(24) uncertain(0)
*List to confirm
vl list vlcategorical
vl list vlcontinuous
*Subsitute to create a group name i factors that add an IDOT prefix to each variable in the list
vl substitute ifactors=i.vlcategorical
display "$ifactors"
display "$continuous"
***Now we fit our lasso model by begining with split  sample into two equal groups; Group one is going to be our training dataset which we will use to select our model
*Group two is our test dataset that we will use to test the prediction  
splitsample, generate(sample1) nsplit(2) rseed(1234)

*Use lasso linear to fit a linear lasso model for the dependent variable which is log_whour sample=1 is include to fit our model using the testing data and I specified random number seed so that our results are reproducible by dafault lasso fits 
lasso linear log_whour ($idemographics) $ifactors $continuous if sample==1, rseed(1234)

**Results from lasso indicates 59 has the smallest cross validation(CV) mean prediction error this suggests that the model with Lambda is 0.00084 is the best for prediction we can type now "cvplot" to create a graph with lamda on the horizontal axis and the cross validation function on the vertical axis
 cvplot
 
 * This graph confirms that the CV function is minimized where lambda equals 0.00084 We can now store the results of this model in the memmory by typing estimates store CV 
 estimates store cv 
 
 * Now I will type lasso knots to create a table of information about each of the models that were fit. 
 lassoknots, display(nonzero osr2 bic)
 
 *We can select the model with lowest BIC from lassoknot table and type this command 
 lassoselect id= 58
 
 *We can view a CV plot by typing CV plots this  plot shows that the cross validation. The CV function is slightly higher for model 58 with a valley of lambda equals 0.00092 but model 58 is more parsimonious with only 37 coefficients rather than 38 coffiencients when lamda equals 0.0084. 
 cvplot
 
 *Now lets store the results of this model as minBIC 
 
 estimates store minBIC
 
 *Selection adaptive model to fit an adaptive lasso model. Adaptive lasso did two lassos and selected model 165 as the best fitting model because it has the smallest CV mean prediction 
 lasso linear log_whour ($idemographics) $ifactors $continuous if sample==1, selection(adaptive) rseed(1234)

 * Store the estimates with the name adaptive.
 estimates store adaptive
 *Now we can use lasso Co F to view a table of the variable that were selected using our three models and also we sort because we want the varaibles with the large standardized to be listed first, that is, the most important are listed first.
lassocoef cv minBIC adaptive, display(coef, standardized) sort(coef, standardized) nofvlabel

*Now am going to used the lasso gof to assess the goodness of fit over our training sample in our testing sample. You can recall that we used sample 1 as our traning data and sample 2 is our testing data that we created using split sample. The results shows that the model with the minimumBIC has the smallest mean squared error and the largest r-square in the 2 which is testing dataset
lassogof cv minBIC adaptive, over(sample) postselection
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 