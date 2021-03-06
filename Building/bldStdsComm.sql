SELECT
	aat.TRAN_AMOUNT feeAmt
	,rbz.VALUE_DESC bldContNam
	,rbz2.VALUE_DESC bldContPhn
	,'{?qStart}'||'/'||'{?fiscYr}' AS startDate
	,'{?qEnd}'||'/'||'{?fiscYr}' AS endDate
	,g3s.GA_FNAME||' '||g3s.GA_LNAME userName
FROM B1PERMIT b
LEFT OUTER JOIN G3STAFFS g3s ON
	b.SERV_PROV_CODE = g3s.SERV_PROV_CODE
	AND b.REC_STATUS = g3s.REC_STATUS
	AND g3s.GA_USER_ID = '{?userId}'
INNER JOIN ACCOUNTING_AUDIT_TRAIL aat ON
	b.SERV_PROV_CODE = aat.SERV_PROV_CODE
	AND b.B1_PER_ID1 = aat.B1_PER_ID1
	AND b.B1_PER_ID2 = aat.B1_PER_ID2
	AND b.B1_PER_ID3 = aat.B1_PER_ID3
	AND b.REC_STATUS = aat.REC_STATUS
	AND aat.ACTION IN ('Payment Applied','Refund Applied','Void Payment Applied')
	AND aat.GF_COD = 'SF110'
LEFT OUTER JOIN RBIZDOMAIN_VALUE rbz ON
	b.SERV_PROV_CODE = rbz.SERV_PROV_CODE
	AND b.REC_STATUS = rbz.REC_STATUS
	AND rbz.BIZDOMAIN = 'REPORT_INFO'
	AND rbz.BIZDOMAIN_VALUE = 'BLD_CONTACT'
LEFT OUTER JOIN RBIZDOMAIN_VALUE rbz2 ON
	b.SERV_PROV_CODE = rbz2.SERV_PROV_CODE
	AND b.REC_STATUS = rbz2.REC_STATUS
	AND rbz2.BIZDOMAIN = 'REPORT_INFO'
	AND rbz2.BIZDOMAIN_VALUE = 'BLD_CONTACT_PHONE'
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Building'
	AND b.B1_PER_TYPE = 'Permit'
	AND (
			aat.TRAN_DATE >= TO_DATE('{?qStart}'||'/'||'{?fiscYr}','MM/DD/YYYY')
			AND aat.TRAN_DATE <= TO_DATE('{?qEnd}'||'/'||'{?fiscYr}','MM/DD/YYYY')
		)
