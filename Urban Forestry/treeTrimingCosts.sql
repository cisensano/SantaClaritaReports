SELECT
	rbzV.dbhGrp
	,rbzV.trimRate
	,gam.G1_ASSET_ID assetId

FROM GASSET_MASTER gam
INNER JOIN GASSET_ATTRIBUTE gatr ON
	gam.SERV_PROV_CODE = gatr.SERV_PROV_CODE
	AND gam.REC_STATUS = gatr.REC_STATUS
	AND gam.G1_ASSET_SEQ_NBR = gatr.G1_ASSET_SEQ_NBR
	AND gatr.G1_ATTRIBUTE_NAME = 'DBH'
	AND NOT gatr.G1_ATTRIBUTE_VALUE = 'Palm Tree'
	INNER JOIN (
		SELECT
			rbz.SERV_PROV_CODE
			,SUBSTR(rbz.BIZDOMAIN_VALUE,1,(INSTR(rbz.BIZDOMAIN_VALUE,'-',1)-1)) minDBH
			,SUBSTR(rbz.BIZDOMAIN_VALUE,(INSTR(rbz.BIZDOMAIN_VALUE,'-',1)+1)
				,LENGTH(rbz.BIZDOMAIN_VALUE)) maxDBH
			,rbz.VALUE_DESC trimRate
			,rbz.BIZDOMAIN_VALUE dbhGrp
		FROM RBIZDOMAIN_VALUE rbz
		WHERE
			2=2
			AND rbz.SERV_PROV_CODE = 'SANTACLARITA'
			AND rbz.BIZDOMAIN = 'UF_DBHTrimCost'
			AND rbz.BIZDOMAIN_VALUE LIKE '%-%'
			AND rbz.REC_STATUS = 'A'
	) rbzV ON
		gatr.SERV_PROV_CODE = rbzV.SERV_PROV_CODE
		AND gatr.G1_ATTRIBUTE_VALUE BETWEEN rbzV.minDBH AND rbzV.maxDBH
INNER JOIN GASSET_ATTRIBUTE gatr2 ON
	gam.SERV_PROV_CODE = gatr2.SERV_PROV_CODE
	AND gam.REC_STATUS = gatr2.REC_STATUS
	AND gam.G1_ASSET_SEQ_NBR = gatr2.G1_ASSET_SEQ_NBR
	AND gatr2.G1_ATTRIBUTE_NAME = 'Zone'	
WHERE
	1=1
	AND gam.SERV_PROV_CODE = 'SANTACLARITA'
	AND gam.REC_STATUS = 'A'
	AND gam.G1_ASSET_GROUP = 'Street'
	AND gam.G1_ASSET_TYPE = 'Tree'

UNION

SELECT
	rbzV.BIZDOMAIN_VALUE AS dbhGrp
	,rbzV.trimRate
	,gam.G1_ASSET_ID assetId

FROM GASSET_MASTER gam
INNER JOIN GASSET_ATTRIBUTE gatr ON
	gam.SERV_PROV_CODE = gatr.SERV_PROV_CODE
	AND gam.REC_STATUS = gatr.REC_STATUS
	AND gam.G1_ASSET_SEQ_NBR = gatr.G1_ASSET_SEQ_NBR
	AND gatr.G1_ATTRIBUTE_NAME = 'DBH'
	AND gatr.G1_ATTRIBUTE_VALUE = 'Palm Tree'
	INNER JOIN RBIZDOMAIN_VALUE rbzV ON
		gatr.SERV_PROV_CODE = rbzV.SERV_PROV_CODE
		AND gatr.G1_ATTRIBUTE_VALUE = rbzV.BIZDOMAIN_VALUE
		AND gatr.REC_STATUS = rbzV.REC_STATUS
		AND rbzV.BIZDOMAIN = 'UF_DBHTrimCost'	
INNER JOIN GASSET_ATTRIBUTE gatr2 ON
	gam.SERV_PROV_CODE = gatr2.SERV_PROV_CODE
	AND gam.REC_STATUS = gatr2.REC_STATUS
	AND gam.G1_ASSET_SEQ_NBR = gatr2.G1_ASSET_SEQ_NBR
	AND gatr2.G1_ATTRIBUTE_NAME = 'Zone'	
WHERE
	1=1
	AND gam.SERV_PROV_CODE = 'SANTACLARITA'
	AND gam.REC_STATUS = 'A'
	AND gam.G1_ASSET_GROUP = 'Street'
	AND gam.G1_ASSET_TYPE = 'Tree'