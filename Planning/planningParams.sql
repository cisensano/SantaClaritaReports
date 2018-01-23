SELECT DISTINCT
	r3s.APPLICATION_STATUS
FROM R3STATYP r3s
INNER JOIN R3APPTYP r3a ON
	r3s.SERV_PROV_CODE = r3a.SERV_PROV_CODE
	AND r3s.REC_STATUS = r3a.REC_STATUS
	AND r3s.R3_PROCESS_CODE = r3a.R1_PROCESS_CODE
WHERE
	1=1
	AND r3s.SERV_PROV_CODE = 'SANTACLARITA'
	AND r3s.REC_STATUS = 'A'
	AND r3a.R1_PER_GROUP = 'Planning'
	AND NOT NULLIF(r3s.APPLICATION_STATUS,'') IS NULL	