* Data Analysis with SAS ;
* D-Lab ;


* load data files ;
data countries;
    infile '/folders/myshortcuts/data/countries.csv' dlm=',' dsd firstobs=2;
    input   country : $2.
            google_country_code : $2.
            country_group : $6.
            name_en : $41.
            name_fr $
            name_de $
            latitude
            longitude;
run;
data unemployment;
    infile '/folders/myshortcuts/data/country_total.csv' dlm=',' dsd firstobs=2;
    input country : $2. seasonality : $5. month : $7. unemployment unemployment_rate;
run;

* split year and month ;
data unemployment;
    set unemployment (rename=(month=year_month));
    year = scan(year_month, 1, '.') * 1;
    month = scan(year_month, 2, '.') * 1;
run;

* reorder variables ;
data unemployment;
    retain country seasonality year month unemployment unemployment_rate;
    set unemployment (drop=year_month);
run;

* unique `seasonality` values ;
proc sql;
    select distinct seasonality
    from unemployment;
quit;

* keep only seasonally adjusted records ;
data unemployment_sa (drop=seasonality);
    set unemployment;
    if seasonality = 'sa' then output;
run;

* number of unique countries ;
proc sql;
    select count(distinct country)
    from unemployment_sa;
quit;

* time period ;
proc sql;
    select min(year) as year_first, max(year) as year_last
    from unemployment_sa;
quit;

* univariate statistics ;
proc univariate data=unemployment_sa;
    var unemployment unemployment_rate;
run;

* sort by country ;
proc sort data=unemployment_sa;
    by country year month;
run;
proc sort data=countries (keep=country country_group name_en)
    force;
    by country;
run;

* merge ;
data unemployment_sa (rename=(name_en=country_name));
    retain country country_group name_en;
    merge unemployment_sa countries;
    by country;
    if country = 'de' then do;
        name_en = scan(name_en, 1, ' ');
    end;
run;

* years of available data ;
proc freq data=unemployment_sa;
    table country_name*year / nocol norow nopercent;
run;

* unemployment means, by country ;
proc means data=unemployment_sa nmiss mean std min max;
    var unemployment;
    class country_name;
run;

* unemployment rate means, by country ;
proc means data=unemployment_sa nmiss mean std min max;
    var unemployment_rate;
    class country_name;
run;

* unemployment rate means, by country type ;
proc means data=unemployment_sa nmiss mean std min max;
    var unemployment_rate;
    class country_group;
run;

* number of countries, by country group ;
proc freq data=countries;
    table country_group / nopercent nocum;
run;

* date formats ;
data unemployment_sa;
    retain country country_group country_name year month date_var;
    set unemployment_sa;
    date_var = input(cats(month, '01', year), MMDDYY8.);
    format date_var MMDDYY8.;
run;

* plotting ;
proc sgplot data=unemployment_sa;
    title 'European Unemployment';
    xaxis label = " ";
    yaxis label = "Unemployment Rate (%)";
    series x = date_var y = unemployment_rate / group=country_name;
run;
proc sgplot data=unemployment_sa
        (where=(country_name='Spain' or
                country_name='Portugal'));
    title 'Spanish and Portuguese Unemployment';
    xaxis label = " ";
    yaxis grid label = "Unemployment Rate (%)";
    series x = date_var y = unemployment_rate / group=country_name;
    keylegend / title="";
run;
