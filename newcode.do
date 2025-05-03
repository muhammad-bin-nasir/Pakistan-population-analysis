* Load your CSV
import delimited "D:\\Momina Docs\\Project\\pakistan_districtwise_population2023.csv", clear

* Initialize asdoc file
asdoc, text(Report on Gender Disparity in Schooling Opportunities in Pakistan) clear save(report.doc)

* Step 1: Create Disparity Variables (Boys - Girls)
generate disparity = total_boys_schools - total_girls_schools
generate calculated_total_schools = total_boys_schools + total_girls_schools
generate disparity_pct = (disparity / calculated_total_schools) * 100

* Step 2: Sort Districts by Disparity (Descending - Biggest Gaps First)
gsort -disparity

* Export District Disparities
asdoc list province district total_boys_schools total_girls_schools disparity disparity_pct, ///
    title(District-level Gender Disparities) append sep(0)

* Step 3: Provincial Average Disparity
collapse (mean) disparity disparity_pct, by(province)

gsort -disparity

* Export Provincial Averages
asdoc list province disparity disparity_pct, title(Provincial Mean Disparities) append sep(0)

* Step 4: Most Balanced Districts
* Re-import original data
import delimited "D:\\Momina Docs\\Project\\pakistan_districtwise_population2023.csv", clear

* Recalculate variables
generate disparity = total_boys_schools - total_girls_schools
generate calculated_total_schools = total_boys_schools + total_girls_schools
generate disparity_pct = (disparity / calculated_total_schools) * 100

* Sort for most balanced
gsort disparity

* Export Most Balanced Districts
asdoc list province district total_boys_schools total_girls_schools disparity in 1/5, ///
    title(Top 5 Most Balanced Districts) append sep(0)

* Step 5: Regression Analysis
asdoc regress disparity population_2023 growth_rate area households density_2023peoplekm, ///
    title(OLS Regression: Absolute Disparity vs Demographic Variables) append

asdoc regress disparity_pct population_2023 growth_rate area households density_2023peoplekm, ///
    title(OLS Regression: Relative Disparity (%) vs Demographic Variables) append

* Bonus: Graphs (saved manually since asdoc does not export graphs)
graph bar disparity, over(district, sort(1) descending label(angle(90) labsize(tiny))) ///
    title("Disparity Between Boys' and Girls' Schools by District", size(vsmall)) ///
    bar(1, color("skyblue")) name(district_disparity_bar, replace)
graph export "district_disparity_bar.png", replace width(1600) height(800)

* Example scatterplots
scatter disparity population_2023
graph export "scatter_disparity_vs_population.png", replace

scatter disparity_pct growth_rate
graph export "scatter_disparitypct_vs_growthrate.png", replace
