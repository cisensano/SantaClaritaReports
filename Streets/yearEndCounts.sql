SELECT
	b.B1_ALT_ID woNum
	,b.B1_PER_SUB_TYPE woGrp
	,b.B1_PER_CATEGORY woSubGrp
	,bc.B1_CHECKLIST_COMMENT proReac
	,b.B1_PER_ID1
	,b.B1_PER_ID2
	,b.B1_PER_ID3
FROM B1PERMIT b
INNER JOIN BCHCKBOX bc ON
	b.SERV_PROV_CODE = bc.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bc.B1_PER_ID1
	AND b.B1_PER_ID2 = bc.B1_PER_ID2
	AND b.B1_PER_ID3 = bc.B1_PER_ID3
	AND b.REC_STATUS = bc.REC_STATUS
	AND bc.B1_CHECKBOX_TYPE = 'GLOBAL INFORMATION'
	AND bc.B1_CHECKBOX_DESC = 'Work Order Type'
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'AMS'
	AND b.B1_PER_TYPE = 'Street'
	AND b.B1_APPL_STATUS = 'Closed'
	AND (
			b.B1_APPL_STATUS_DATE >= {?startDate}
			AND b.B1_APPL_STATUS_DATE <= {?endDate}
			)