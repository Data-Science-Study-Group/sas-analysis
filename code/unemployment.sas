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
data country_totals;
    infile '/folders/myshortcuts/data/country_total.csv' dlm=',' dsd firstobs=2;
    input country : $2. seasonality : $5. month unemployment unemployment_rate;
run;

* split year and month ;
data country_totals;
    set country_totals (rename=(month=year_month));
    year = scan(year_month, 1, '.') * 1;
    month = scan(year_month, 2, '.') * 1;
run;
