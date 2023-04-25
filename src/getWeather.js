const fs = require('fs')

/*
Field#  Name                           Units
---------------------------------------------
   1    WBANNO                         XXXXX
   2    LST_DATE                       YYYYMMDD
   3    CRX_VN                         XXXXXX
   4    LONGITUDE                      Decimal_degrees
   5    LATITUDE                       Decimal_degrees
   6    T_DAILY_MAX                    Celsius
   7    T_DAILY_MIN                    Celsius
   8    T_DAILY_MEAN                   Celsius
   9    T_DAILY_AVG                    Celsius
   10   P_DAILY_CALC                   mm
   11   SOLARAD_DAILY                  MJ/m^2
   12   SUR_TEMP_DAILY_TYPE            X
   13   SUR_TEMP_DAILY_MAX             Celsius
   14   SUR_TEMP_DAILY_MIN             Celsius
   15   SUR_TEMP_DAILY_AVG             Celsius
   16   RH_DAILY_MAX                   %
   17   RH_DAILY_MIN                   %
   18   RH_DAILY_AVG                   %
   19   SOIL_MOISTURE_5_DAILY          m^3/m^3
   20   SOIL_MOISTURE_10_DAILY         m^3/m^3
   21   SOIL_MOISTURE_20_DAILY         m^3/m^3
   22   SOIL_MOISTURE_50_DAILY         m^3/m^3
   23   SOIL_MOISTURE_100_DAILY        m^3/m^3
   24   SOIL_TEMP_5_DAILY              Celsius
   25   SOIL_TEMP_10_DAILY             Celsius
   26   SOIL_TEMP_20_DAILY             Celsius
   27   SOIL_TEMP_50_DAILY             Celsius
   28   SOIL_TEMP_100_DAILY            Celsius
*/
const format = [ "WBANNO", "LST_DATE" ,"CRX_VN",
    "LONGITUDE",            "LATITUDE",  "T_DAILY_MAX", 
    "T_DAILY_MIN",          "T_DAILY_MEAN",               
    "T_DAILY_AVG",          "P_DAILY_CALC",                   
    "SOLARAD_DAILY",        "SUR_TEMP_DAILY_TYPE" ,        
    "SUR_TEMP_DAILY_MAX",   "SUR_TEMP_DAILY_MIN",            
    "SUR_TEMP_DAILY_AVG" ,  "RH_DAILY_MAX",                   
    "RH_DAILY_MIN" ,        "RH_DAILY_AVG",                   
    "SOIL_MOISTURE_5_DAILY" ,"SOIL_MOISTURE_10_DAILY",         
    "SOIL_MOISTURE_20_DAILY","SOIL_MOISTURE_50_DAILY",         
    "SOIL_MOISTURE_100_DAILY","SOIL_TEMP_5_DAILY",              
    "SOIL_TEMP_10_DAILY" ,    "SOIL_TEMP_20_DAILY",             
    "SOIL_TEMP_50_DAILY" ,    "SOIL_TEMP_100_DAILY"           
]
const FILENAMES= ['CRND0103-2022-NY_Ithaca_13_E.txt', 'CRND0103-2021-NY_Ithaca_13_E.txt', 'CRND0103-2020-NY_Ithaca_13_E.txt', 'CRND0103-2019-NY_Ithaca_13_E.txt','CRND0103-2018-NY_Ithaca_13_E.txt']
const OUT= 'CRND0103-2022-NY_Ithaca_13_E.csv'

async function getWeather(filenames){
    let out        = format.join(',') + '\n'
    for (let i=0; i<filenames.length; i++){
        let contents   = fs.readFileSync(filenames[filenames.length-i-1], 'utf8', {root: '.'}).replace(/ C /g, '').replace(/[ ]+/g,',')
        let lines      = contents.split('\n').filter(line=>!line.includes('-99'))
        out           += lines.join('\n')
    }
    console.log(out.split('\n').length)
    fs.writeFileSync(OUT,out)
}

getWeather(FILENAMES)
