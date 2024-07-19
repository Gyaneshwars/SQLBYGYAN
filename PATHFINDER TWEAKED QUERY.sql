USE Pathfinder
--SQL QUERY DEVELOPER-->GNANESHWAR SRAVANE
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-09-19 06:00:00' 
SET @toDate = '2023-09-20 06:00:00' 

IF OBJECT_ID('TEMPDB..#KEYPEIN') IS NOT NULL DROP TABLE #KEYPEIN  CREATE TABLE #KEYPEIN (KEYPERSON int,SPGMIEIN int,LOGINNAME VARCHAR(70)); INSERT INTO #KEYPEIN VALUES  
(2546055,810844566,'abhishek_khawale'),(2648839,810845308,'abhishek_tiwari2'),(750562,710815745,'mabuashwad'),(2374568,810842584,'adarsh_jaiswal'),(1882160,810838793,'aditi_sharma'),(752581,710834894,'safrin'),(2655816,810845459,'agresh_agrawal'),(777660,810823440,'athavva'),(2467299,810843902,'aishwarya_drablani'),(2648827,810845264,'a_chevula'),(1268322,810831946,'aishwarya_pandit'),(1900500,810839118,'akshita_kedawat'),(2379717,810842856,'aman_kumar_patidar'),(2648830,810845296,'amit_brijawasi'),(751294,710823811,'auppuluri'),(750792,710818702,'yanantababu'),(752042,710830729,'asistla'),(752053,710830750,'asatti'),(752109,710831346,'avadapalli'),(2379645,810842667,'a_saxena'),(2648836,810845305,'aparna_paliwal'),(1077018,810829125,'apeksha_agarwal'),(1103940,810829711,'archana_somarapu'),(754771,810812002,'arokkam'),(751105,710822013,'aneella'),(753336,710841200,'aaddagalla'),(754992,810812870,'a_atakamwar'),(750591,710816243,'achinthoti'),(2655804,810845434,'ayasha_gulgulia'),(2379711,810842820,'ayush_joshi1'),(2733919,810845995,'ayushi_patel'),(2648824,810845261,'ayushi_rathore'),(2648844,810845314,'shivaprasad_rao_b'),(750638,710816636,'bkothaluru'),(750904,710819839,'bbadisa'),(752058,710830759,'bshivannagari'),(751893,710829841,'bboya'),(2374461,710819857,'b_komala'),(2546054,810844562,'bhawna_meghani'),(752572,710834884,'vboyapati'),(1533274,810827955,'brij_ruparel'),(755425,810814972,'cmisoorappagari'),(1591786,810837097,'c_nainolla'),(751989,710830360,'cvadla'),(751232,710822994,'vchaudarapu'),(751082,710821676,'cmalasani'),(2467286,810843846,'chirag_chudasama'),(751235,710822997,'cmungamuri'),(751938,710830050,'hchitra'),(2546050,810844552,'chitra_tare'),(751231,710822992,'gdamera'),(2467283,810843834,'d_patel2'),(298665,510298665,'dasharaths'),(2648840,810845310,'deep_shikha_kumari'),(2698341,810845661,'devanshi_bhatt'),(2698376,810845714,'dhairya_mandowra'),(2648834,810845301,'dharani_pabboju'),(2655811,810845447,'dheeraj_a_v'),(1005826187,810825710,'dhruv_mehta'),(1900509,810839137,'disha_upmanyu'),(1322479,810833106,'drashti_jani'),(1019588,810827955,'ebin_eldhose'),(750697,710817406,'emohammad'),(754165,710845701,'etangudu'),(2057081,810841073,'fahad_sheikh'),(753258,710840701,'gbrundavanam'),(2022748,810840590,'gaurang_mrug'),(2648855,810845408,'geetha_devi_g'),(752577,710834890,'gmahmood'),(752569,710834878,'gsravane'),(762588,810821418,'GOONJALD'),(2655803,810845430,'gourav_sahoo'),(2698396,810845773,'govind_maheshwari'),(752436,710834043,'hmupparaju'),(751897,710829846,'hjaldu'),(762589,810821420,'HARDIKVP'),(752893,710838112,'hbattili'),(752517,710834513,'hbommasetty'),(762590,810821419,'HARSHILHB'),(2698378,810845717,'hem_shah'),(752437,710834044,'hchinta'),(2467278,810843813,'m_maddirala'),(2655814,810845456,'hiren_brahmbhatt'),(2374560,810842567,'honey_makrani'),(2343506,810841995,'isha_aggarwal'),(2648850,810845336,'isha_chana'),(1882166,810838802,'isha_pandya'),(750914,710819856,'jbalasubramanyam'),(2655805,810845435,'janak_raj_upadhyay'),(752055,710830754,'jparikapalli'),(751506,710825998,'jaligi'),(2648860,810845414,'jay_majhi'),(2648859,810845413,'jesica_jain'),(1005917308,810826503,'jhanvi_ruparel'),(752046,710830738,'jvelicheti'),(750294,710810985,'skadalamkodi'),(750404,710813736,'skakarparty'),(755113,810813326,'kmohammad'),(751943,710830057,'kpolisetty'),(752518,710834514,'kpativada'),(750588,710816237,'jkanmuri'),(752801,710836596,'kyanamadala'),(2698406,810845788,'kashish_khan'),(2057089,810841117,'kaushal_chauhan'),(1240811,810831627,'kavya_marsetti'),(751857,710829581,'mkintali'),(751971,710830326,'kkudumula'),(750589,710816238,'kvidiyala'),(1900504,810839124,'kirti_parihar'),(750719,710817878,'krenuvardhan'),(755294,810814309,'kryali'),(750807,710818750,'kareti'),(2709554,810845790,'krutik_sanghvi'),(751511,710826009,'kpaidi'),(750405,710813738,'skummari'),(752566,710834873,'lyedlapalli'),(1005913743,810826450,'lalit_pawar'),(755698,810816152,'lchichili'),(2648843,810845313,'latika_pardeshi'),(752626,710835217,'lthammalithota'),(751295,710823812,'lboorla'),(751992,710830365,'lmote'),(751350,710824425,'mninnekar'),(750255,710810416,'rmadduri'),(753192,710840250,'mmysa'),(752625,710835216,'madhuri_a'),(751298,710823818,'muppalapati'),(750417,710813778,'mnarra'),(1882168,810838809,'mangalam_parwal'),(750449,710814092,'mkadimisetti'),(751945,710830063,'mkalupukuri'),(2648829,810845295,'manoj_kumar_b'),(1882155,810838788,'manu_saini'),(750660,710817067,'amatukumilli'),(1282239,810832241,'maunil_sheth'),(756804,510756804,'mehulc'),(2655809,810845439,'merlin_varghese'),(2648838,810845307,'mitali_singh'),(750296,710810989,'jmohammad'),(750554,710815713,'amohammed'),(1978809,810840137,'mohit_dhandhariya'),(751300,710823823,'mavusula'),(751990,710830361,'mtiriveedhi'),(1077027,810829170,'c_mounika'),(750674,710817098,'jmudadla'),(750924,710819885,'mkuppireddy'),(1882163,810838798,'muskan_sen'),(754670,810811386,'ngoli'),(751509,710826002,'nsarvasiddi'),(751236,710822998,'nnirukonda'),(750409,710813742,'snagandla'),(753127,710839847,'nbachamgari'),(751982,710830351,'nsomisetty'),(750870,710819342,'npilligundla'),(1944807,810839642,'nandinie_dubey'),(752578,710834891,'npinnapureddy'),(751065,710821425,'nkotha'),(754761,810811981,'nponnada'),(750258,710810424,'cnarreddula'),(750632,710816618,'dnatwa'),(1316938,810832673,'navitha_kandadi'),(1571828,810836853,'nayanshree_shinde'),(754087,710845388,'npanda'),(773092,810818827,'ndorsula'),(2648831,810845297,'nikhitha_jaiswal'),(2546058,810844577,'nikita_pal'),(2057122,810841322,'niranjan_kothari'),(2379652,810842681,'nishil_hemnani'),(2648835,810845302,'nitish_dobriyal'),(763273,810821502,'nislam'),(2698332,810845652,'om_bakraniya'),(1548048,810836425,'pallavi_agrawal'),(2022773,810840715,'parag_gupta'),(750763,710818250,'vparasa'),(2655812,810845450,'pavan_kumar_basava'),(2467302,810843918,'payal_kotwani'),(750694,710817401,'npeddakotla'),(752041,710830728,'spenmetsa'),(1230395,810831496,'piyush_raychura'),(693271,510693271,'poojaj'),(752020,710830545,'pdara'),(750765,710818252,'pragula'),(2698334,810845654,'prachi_jain2'),(1900506,810839126,'prachi_yadav'),(751172,710822499,'prondla'),(754671,810811387,'pvupputuri'),(2379642,810842664,'p_paliwal'),(754915,810812497,'pramita_gedam'),(1131667,810829990,'p_pasuparthy'),(765020,810821559,'prasannb'),(2648833,810845300,'prasthi_samani'),(2409632,810843222,'pratik_baid'),(2648845,810845315,'pravallika_kadari'),(751917,710829894,'paitha'),(2467295,810843889,'praveen_gavhade_p'),(750381,710813358,'pracharla'),(1882165,810838801,'priya_mantri'),(1927885,810839198,'priyansh_jain1'),(2546049,810844551,'priyanshu_rathore'),(753522,710842493,'pguin'),(2648832,810845298,'rahul_mondal'),(2648825,810845262,'raja_epari'),(755351,810814624,'rkudumula'),(751937,710830049,'rbhajanthri'),(750407,710813740,'rpittala'),(752045,710830736,'ryekkaluru'),(1005794439,810825224,'ram_agrawal'),(750909,710819845,'rsurla'),(753820,710844178,'rsheela'),(751858,710829584,'rkurakula'),(752515,710834511,'aramadevi'),(754787,810812024,'nramadevi'),(780023,810823492,'sramamani'),(753480,710842233,'rdora'),(751898,710829848,'rjajam'),(751936,710830048,'rnutheti'),(751970,710830325,'rkolli'),(750615,710816328,'rgajula'),(750794,710818704,'rthoti'),(753552,710842698,'rvadada'),(752942,710838920,'rboddu'),(751894,710829842,'rpodendla'),(752561,710834868,'rkolan'),(751291,710823807,'rbarad'),(2696484,810845366,'r_harishwar_reddy'),(1882156,810838789,'rashi_agrawal'),(750915,710819860,'rkaturi'),(752564,710834871,'rponaganti'),(750616,710816329,'bravipati'),(2546059,810844578,'ritesh_maheshwari2'),(2698322,810845629,'riya_singh2'),(2655813,810845454,'rohit_jain5'),(1900505,810839125,'ronak_maheshwari'),(2343401,810841842,'ronak_puri'),(1183251,810830718,'roshni_panchal'),(2379662,810842693,'rushali_singh'),(1071018,810829290,'ruta_shah'),(2648842,810845312,'sachin_pawar'),(2655810,810845442,'sagnik_gupta'),(756487,810819450,'sbrundavanam'),(2648826,810845263,'sai_divya_balivada'),(1005913747,810826462,'sakshi_periwal'),(2648852,810845379,'sakshi_uradi'),(750720,710817879,'asala'),(2698383,810845743,'samarpita_dhar'),(751299,710823820,'snutalapati'),(2379693,810842765,'samruddhi_shrimali'),(756225,810818529,'sbollu'),(2546065,810844592,'saniya_neema'),(751296,710823813,'sbotthamolla'),(750721,710817881,'smethuku'),(752019,710830544,'smedapati'),(750544,710815382,'ssantosh'),(755352,810814625,'ssamudrala'),(752570,710834881,'snemali'),(754166,710845703,'saritam'),(757734,810820502,'rgarlapati'),(754892,810812406,'snandeekam'),(755346,810814601,'siyili'),(750727,710817893,'smadala'),(2655802,810845429,'selvin_sunny'),(2655807,810845437,'shaheena_p'),(750656,710817060,'nshaik'),(754058,710845330,'shalini_bhardwaj'),(751896,710829845,'spalakuri'),(2546063,810844585,'shikhar_sengar'),(751452,710825482,'sganji'),(2374587,810842641,'s_agrawal2'),(2343507,810841996,'shivangi_agrawal'),(2648841,810845311,'shivani_vaishnav'),(2374570,810842589,'shivika_bhatnagar'),(2791934,810845776,'shobhit_jain'),(2655799,810845304,'shraddha_agrawal'),(2546075,810844680,'shraddha_rathore'),(2698316,810845619,'shubh_verma'),(2379647,810842669,'s_gangrade'),(1900507,810839127,'shubhashish_vaidya'),(1189225,810830674,'s_beerelli'),(752944,710838923,'sjada'),(756105,810818079,'svankineni'),(762317,810821224,'clanka'),(751905,710829868,'asiva'),(753126,710839846,'sivajyothi_cherukuri'),(750795,710818705,'ssomisetty'),(2057085,810841099,'sonali_mohanty'),(754562,810810711,'sbalagiri'),(2698386,810845748,'sonia_sharma3'),(752514,710834510,'spaspunuri'),(1591793,810837135,'soumya_raparthi'),(2379706,810842810,'soumya_yadav'),(751494,710825966,'sravanthi_merugu'),(2648857,810845411,'sri_hari_ayinampudi'),(751967,710830320,'schava'),(752627,710835218,'smuppalla'),(752111,710831349,'spullai'),(754669,810811385,'skommu'),(751984,710830353,'sbollam'),(750154,710808683,'psrinivas'),(750673,710817097,'spolepally'),(752108,710831345,'sthodupunuri'),(751017,710820964,'spogula'),(2698369,810845699,'srishti_malviya'),(2648837,810845306,'steffy_biju'),(2374558,810842563,'stuti_yadav'),(752599,710834927,'sgopireddi'),(756227,810818531,'sboosetty'),(759761,810820623,'sarla'),(751859,710829585,'nsuman'),(755816,810816626,'sgudumuru'),(780026,810823496,'ssunetra'),(755335,810814490,'sdaggupati'),(751512,710826011,'smallareddi'),(752576,710834889,'sbuddhi'),(751986,710830355,'sboya'),(751503,710825995,'svaskuri'),(755123,810813353,'sbandaroo'),(1571827,810836852,'sweta_shukla'),(754571,810810725,'smada'),(1548047,810836424,'tanay_dusad'),(1882161,810838795,'tanya_agrawal'),(2409634,810843234,'tarun_soni2'),(762591,810821448,'TARUNS'),(750590,710816242,'sthallapalli'),(750908,710819844,'vthota'),(753684,710843592,'tvanka'),(754821,810812102,'tanasi'),(753344,710841220,'uboddu'),(754786,810812023,'ukurva'),(751941,710830054,'uchekka'),(751902,710829861,'uvaddadi'),(752943,710838922,'vkukunuri'),(751233,710822995,'lvadakattu'),(2655806,810845436,'vaishali_saraswat'),(777661,810823494,'vboga'),(1198781,810831028,'vaishnavi_narla'),(750911,710819850,'vvallabhapuram'),(750913,710819855,'vboreddigari'),(752054,710830752,'vvani'),(2379646,810842668,'vanshika_lattoo'),(757027,510757027,'veenac'),(757730,810820512,'vdonthikurthi'),(750670,710817093,'vboddu'),(755296,810814313,'vvadlani'),(752018,710830543,'vvaddineedi'),(752565,710834872,'vmuthyam'),(751234,710822996,'vgolagani'),(756500,810819545,'vpeethala'),(751895,710829843,'vgadhamsetty'),(752171,710831719,'vbaktula'),(750935,710819909,'vraghavapurapu'),(750871,710819343,'vgalepelli'),(751412,710825015,'vvatti'),(751907,710829870,'vmukku'),(752017,710830537,'vvadlakonda'),(751348,710824421,'vkatta'),(753136,710839863,'vdaram'),(754661,810811369,'vtulluru'),(755300,810814321,'vgalam'),(751293,710823810,'nvenu'),(2655815,810845457,'vijay_kethavath'),(751916,710829893,'vburugu'),(2546066,810844598,'v_tiwari'),(2696486,810845473,'vinay_chandnani'),(2655808,810845438,'vishal_sarakar'),(752044,710830735,'vshivvannolla'),(2546056,810844568,'vishva_rana'),(750510,710814762,'pvoona'),(750450,710814093,'ryamala'),(750826,710819243,'ykonduri')

IF OBJECT_ID ('TEMPDB..#GYAN') IS NOT NULL DROP TABLE #GYAN
SELECT DISTINCT CONVERT(VARCHAR(10), TASKINSTANCECOMPLETED-'0:30', 101) AS FINALDATE,P1.KEYPERSON,P.SPGMIEIN, P1.LOGINNAME,IPS.KEYPROCESSSTREAM,
IPS.STREAMNAME, IPI.PROCESSINSTANCEAPPIANID,IPI.ProcessInstanceInstantiated,TI.TASKINSTANCEBEGUN + '05:30' AS TASKINSTANCEBEGUN,
TI.TASKINSTANCECOMPLETED +  '05:30' AS TASKINSTANCECOMPLETED,TI.TASKINSTANCEEFFORT,TI.EXPECTEDTASKEFFORT,IPI.PROCESSWORKUNITS,TI.SNLANALYSTTASKENTRY,PN.INTERNALNOTES,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE,A.AppianUserGroupName,TS.TaskDisplayName
INTO #GYAN 
FROM PROCESSINSTANCE IPI
INNER JOIN PROCESSSTREAM IPS ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM AND IPS.UPDOPERATION < 2
INNER JOIN DBO.PROCESSSTREAMGROUP PG ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
JOIN TASKINSTANCE TI ON IPI.KEYPROCESSINSTANCE = TI.KEYPROCESSINSTANCE AND  TI.UPDOPERATION < 2
INNER JOIN DBO.TaskStream TS on ts.KeyTaskStream=ti.KeyTaskStream

INNER JOIN DBO.AppianUserGroup A on A.KeyAppianUserGroup=ts.KeyAppianUserGroup
JOIN DBO.PROCESSDATAVALUE PDV ON PDV.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN DBO.PROCESSNOTES PN ON PN.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN #KEYPEIN P ON TI.KEYPERSON = P.KEYPERSON
LEFT JOIN INTERNALUSEONLY.DBO.EMPLOYEE P1 ON TI.KEYPERSON = P1.KEYPERSON
WHERE  
IPI.UPDOPERATION < 2
AND TI.TASKINSTANCECOMPLETED + '05:30' >= @frDate
AND TI.TASKINSTANCECOMPLETED + '05:30' <= @toDate
AND IPS.KEYDEPARTMENT = 143 
AND IPS.KEYPROCESSSTREAM IN (57878,56981,56832,53683,53687,50749,51909,53135,53455,53475,53437,54565,54566,54730,54688,55660,53702,53475,53713,57294,53437,50188,49730,51277,53793,53988,49730,53702,52947,26424,24818,26425,50188,55529,53446,55097,53470,53489,53490,54760,50749,54867,55566,55577,29129,54560,56008,56117,26425,26424,53445,55239,56649,55856,57791,57904,57903,15146,56812,56774,56814,56776,56772,56788,51406,53954,28783,29927,57316,55220,57276,57791)


IF OBJECT_ID ('TEMPDB..#GYAN2') IS NOT NULL DROP TABLE #GYAN2
SELECT DISTINCT * INTO #GYAN2 FROM (SELECT FINALDATE,KEYPERSON,ProcessInstanceInstantiated,SPGMIEIN, LOGINNAME,KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID,AppianUserGroupName,TaskDisplayName ,TASKINSTANCEBEGUN,TASKINSTANCECOMPLETED,TASKINSTANCEEFFORT,EXPECTEDTASKEFFORT,SNLANALYSTTASKENTRY,ProcessWorkUnits,
INTERNALNOTES,FIELDIDENTIFIER,CAST(PROCESSFIELDVALUE AS VARCHAR(MAX)) PROCESSFIELDVALUE FROM #GYAN)
AS GYANSOURCE
PIVOT
(MAX (PROCESSFIELDVALUE) FOR FIELDIDENTIFIER IN ([TaskName],[TaskDetails],[NoofUnits],[Comment]
))
AS GYANPIVOT
WHERE KEYPROCESSSTREAM<>51277
UNION ALL
SELECT DISTINCT * FROM (SELECT FINALDATE,KEYPERSON,ProcessInstanceInstantiated,SPGMIEIN, LOGINNAME,KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID,AppianUserGroupName,TaskDisplayName ,TASKINSTANCEBEGUN,TASKINSTANCECOMPLETED,TASKINSTANCEEFFORT,EXPECTEDTASKEFFORT,SNLANALYSTTASKENTRY,ProcessWorkUnits,
INTERNALNOTES,FIELDIDENTIFIER,CAST(PROCESSFIELDVALUE AS VARCHAR(MAX)) PROCESSFIELDVALUE FROM #GYAN)
AS GYANSOURCE
PIVOT
(MAX (PROCESSFIELDVALUE) FOR FIELDIDENTIFIER IN ([TaskName],[TaskDetails],[NoofUnits],[Comment]
))
AS GYANPIVOT
WHERE KEYPROCESSSTREAM=51277 AND snlanalysttaskentry=0


SELECT * FROM #GYAN2