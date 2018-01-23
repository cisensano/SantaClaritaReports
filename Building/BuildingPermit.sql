SELECT
	NVL(TO_CHAR(b3aV.B1_HSE_NBR_START),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_DIR),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_NAME),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_SUFFIX),' '),'') addr
	,b3aV.B1_UNIT_TYPE unitType
	,b3aV.B1_UNIT_START unitNbr
	,owner.ownerName
	,COALESCE(b3c.busName,b3c.fullName) tenantNam
	,arch.B1_BUS_NAME archName
	,eng.B1_BUS_NAME engName
	,contra.B1_BUS_NAME contraName
	,contra.B1_LICENSE_NBR contraLicNbr
	,CASE WHEN clsCnt.classCodeCnt = 1 THEN g3at.G1_ATTRIBUTE_VALUE
		WHEN clsCnt.classCodeCnt > 1 THEN 'Multi'
		WHEN clsCnt.classCodeCnt < 1 THEN 'NA'
	END AS classCode
	,contra.B1_ADDRESS1
	,contra.B1_ADDRESS2
	,contra.B1_ADDRESS3
	,contra.B1_CITY
	,contra.B1_STATE
	,contra.B1_ZIP
	,contra.B1_PHONE1
	,g3atrV.wcCoNam
	,g3atrV.wcAgntNam
	,g3atrV.wcAgntPhn
	,g3atrV.wcPolicyNbr
	,g3atrV.wcExpDate
	,b.B1_ALT_ID permitNbr
	,b3pV.B1_PARCEL_NBR parcelNbr
	,b3pV.B1_TRACT parcelTract
	,b3pV.B1_LOT parcelLot
	,bwd.B1_WORK_DESC descOfWork
	,(
		SELECT
			LISTAGG(DECODE(bc.B1_CHECKBOX_DESC,'Other Description',bc.B1_CHECKLIST_COMMENT
					,bc.B1_CHECKBOX_DESC),', ') WITHIN GROUP (ORDER BY bc.B1_CHECKBOX_DESC)
		FROM BCHCKBOX bc
		WHERE
			2=2
			AND bc.SERV_PROV_CODE = b.SERV_PROV_CODE
			AND bc.B1_PER_ID1 = b.B1_PER_ID1
			AND bc.B1_PER_ID2 = b.B1_PER_ID2
			AND bc.B1_PER_ID3 = b.B1_PER_ID3
			AND bc.REC_STATUS = b.REC_STATUS
			AND bc.B1_CHECKBOX_TYPE = 'PROJECT INFORMATION'
			AND bc.B1_CHECKBOX_DESC IN ('Change of Use / Occupancy (for example: office to retail)'
				,'Change Type of Construction','New Building or Structure'
				,'Improvement / Alteration / Remodel (existing space)','Repair','Demolition'
				,'Temporary / Event','Addition','Other','Other Description')
			AND NOT NULLIF(bc.B1_CHECKLIST_COMMENT,'') IS NULL
			AND bc.B1_CHECKLIST_COMMENT LIKE 
				CASE WHEN bc.B1_CHECKBOX_DESC IN ('Addition','Other Description') THEN '%'
				ELSE 'CHECKED' END
		)natreWork
	,(
		SELECT
			LISTAGG(bastv.ATTRIBUTE_VALUE,', ') WITHIN GROUP (ORDER BY bastv.ATTRIBUTE_VALUE)
		FROM BAPPSPECTABLE_VALUE bastv
		WHERE
			2=2
			AND bastv.SERV_PROV_CODE = b.SERV_PROV_CODE
			AND bastv.B1_PER_ID1 = b.B1_PER_ID1
			AND bastv.B1_PER_ID2 = b.B1_PER_ID2
			AND bastv.B1_PER_ID3 = b.B1_PER_ID3
			AND bastv.REC_STATUS = b.REC_STATUS
			AND bastv.TABLE_NAME = 'OCCUPANCY'
			AND bastv.COLUMN_NAME = 'Occupancy Group'
		) occGrp
	,asiPiv.consType
	,asiPiv.useGrp
	,asiPiv.useDetl
	,asiPiv.structType
	,asiPiv.nbrStrs
	,asiPiv.totSqFoot
	,gp1.GA_FNAME||' '||gp1.GA_LNAME issuedBy
	,gp2.GA_FNAME||' '||gp2.GA_LNAME apprvdBy
	,gp1.G6_STAT_DD issueDate
	,gp2.G6_STAT_DD apprvdDate
	,gp3.GA_FNAME||' '||gp3.GA_LNAME inspBy
	,gp3.G6_STAT_DD inspDate
	,asiPiv.applCode
	,(
		SELECT
			LISTAGG(bc.B1_CHECKBOX_DESC,', ') WITHIN GROUP (ORDER BY bc.B1_CHECKBOX_DESC)
		FROM BCHCKBOX bc
		WHERE
			2=2
			AND bc.SERV_PROV_CODE = b.SERV_PROV_CODE
			AND bc.B1_PER_ID1 = b.B1_PER_ID1
			AND bc.B1_PER_ID2 = b.B1_PER_ID2
			AND bc.B1_PER_ID3 = b.B1_PER_ID3
			AND bc.REC_STATUS = b.REC_STATUS
			AND bc.B1_CHECKBOX_TYPE = 'TRADES INCLUDED'
			AND bc.B1_CHECKBOX_DESC IN ('Mechanical','Electrical','Plumbing','Sewer')
			AND bc.B1_CHECKLIST_COMMENT = 'CHECKED'
		) tradesIncl
	,asiPiv.useRestr
	,CASE WHEN bvl.G3_CALC_VALUE > bvl.G3_VALUE_TTL THEN bvl.G3_CALC_VALUE
		ELSE bvl.G3_VALUE_TTL
	END AS valuatn
	,bpd.TOTAL_FEE totalFees
	,f4pV.INVOICE_NBR invoiceNbr
	,f4pV.PAYMENT_DATE pmtDate
	,asiPiv.projNotes

FROM B1PERMIT b
LEFT OUTER JOIN (
	SELECT
		f4p.SERV_PROV_CODE
		,f4p.B1_PER_ID1
		,f4p.B1_PER_ID2
		,f4p.B1_PER_ID3
		,f4p.PAYMENT_DATE
		,x4p.INVOICE_NBR
	FROM F4PAYMENT f4p
	INNER JOIN X4PAYMENT_INVOICE x4p ON
		f4p.SERV_PROV_CODE = x4p.SERV_PROV_CODE
		AND f4p.REC_STATUS = x4p.REC_STATUS
		AND f4p.PAYMENT_SEQ_NBR = x4p.PAYMENT_SEQ_NBR
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = f4p.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = f4p.B1_PER_ID1
		AND bH.B1_PER_ID2 = f4p.B1_PER_ID2	
		AND bH.B1_PER_ID3 = f4p.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	WHERE
		2=2
		AND f4p.SERV_PROV_CODE = 'SANTACLARITA'
		AND f4p.REC_STATUS = 'A'
		AND x4p.INVOICE_NBR = (
			SELECT
				MAX(x4pS.INVOICE_NBR)
			FROM X4PAYMENT_INVOICE x4pS
			WHERE
				3=3
				AND x4pS.SERV_PROV_CODE = x4p.SERV_PROV_CODE
				AND x4pS.PAYMENT_SEQ_NBR = x4p.PAYMENT_SEQ_NBR	
				AND x4pS.REC_STATUS = 'A'
			)
) f4pV ON
	b.SERV_PROV_CODE = f4pV.SERV_PROV_CODE
	AND b.B1_PER_ID1 = f4pV.B1_PER_ID1
	AND b.B1_PER_ID2 = f4pV.B1_PER_ID2
	AND b.B1_PER_ID3 = f4pV.B1_PER_ID3
	
LEFT OUTER JOIN BVALUATN bvl ON
	b.SERV_PROV_CODE = bvl.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bvl.B1_PER_ID1
	AND b.B1_PER_ID2 = bvl.B1_PER_ID2
	AND b.B1_PER_ID3 = bvl.B1_PER_ID3
	AND b.REC_STATUS = bvl.REC_STATUS
LEFT OUTER JOIN BPERMIT_DETAIL bpd ON
	b.SERV_PROV_CODE = bpd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bpd.B1_PER_ID1
	AND b.B1_PER_ID2 = bpd.B1_PER_ID2
	AND b.B1_PER_ID3 = bpd.B1_PER_ID3
	AND b.REC_STATUS = bpd.REC_STATUS
--BWORKDES
LEFT OUTER JOIN BWORKDES bwd ON
	b.SERV_PROV_CODE = bwd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bwd.B1_PER_ID1
	AND b.B1_PER_ID2 = bwd.B1_PER_ID2
	AND b.B1_PER_ID3 = bwd.B1_PER_ID3
	AND b.REC_STATUS = bwd.REC_STATUS
LEFT OUTER JOIN (
	SELECT
		b3lp.SERV_PROV_CODE
		,b3lp.B1_PER_ID1
		,b3lp.B1_PER_ID2
		,b3lp.B1_PER_ID3
		,b3lp.B1_BUS_NAME
	FROM B3CONTRA b3lp
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = b3lp.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = b3lp.B1_PER_ID1
		AND bH.B1_PER_ID2 = b3lp.B1_PER_ID2	
		AND bH.B1_PER_ID3 = b3lp.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	WHERE
		2=2
		AND b3lp.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3lp.REC_STATUS = 'A'
		AND b3lp.B1_LICENSE_TYPE = 'Architect'
		AND b3lp.B1_LICENSE_NBR = (
			SELECT
				MIN(b3lpS.B1_LICENSE_NBR)
			FROM B3CONTRA b3lpS
			WHERE
				2=2
				AND b3lpS.SERV_PROV_CODE = b3lp.SERV_PROV_CODE
				AND b3lpS.B1_PER_ID1 = b3lp.B1_PER_ID1
				AND b3lpS.B1_PER_ID2 = b3lp.B1_PER_ID2
				AND b3lpS.B1_PER_ID3 = b3lp.B1_PER_ID3
				AND b3lpS.REC_STATUS = b3lp.REC_STATUS
				AND b3lpS.B1_LICENSE_TYPE = 'Architect'
				AND COALESCE(b3lpS.B1_PRINT_FLAG,'N') = (
					SELECT
						MAX(COALESCE(b3lpS2.B1_PRINT_FLAG,'N'))
					FROM B3CONTRA b3lpS2
					WHERE
						3=3
						AND b3lpS2.SERV_PROV_CODE = b3lpS.SERV_PROV_CODE
						AND b3lpS2.B1_PER_ID1 = b3lpS.B1_PER_ID1
						AND b3lpS2.B1_PER_ID2 = b3lpS.B1_PER_ID2
						AND b3lpS2.B1_PER_ID3 = b3lpS.B1_PER_ID3
						AND b3lpS2.REC_STATUS = b3lpS.REC_STATUS
						AND b3lpS2.B1_LICENSE_TYPE = 'Architect'
					)
				)
			) arch ON
	b.SERV_PROV_CODE = arch.SERV_PROV_CODE
	AND b.B1_PER_ID1 = arch.B1_PER_ID1
	AND b.B1_PER_ID2 = arch.B1_PER_ID2
	AND b.B1_PER_ID3 = arch.B1_PER_ID3
LEFT OUTER JOIN (
	SELECT
		b3lp.SERV_PROV_CODE
		,b3lp.B1_PER_ID1
		,b3lp.B1_PER_ID2
		,b3lp.B1_PER_ID3
		,b3lp.B1_BUS_NAME
	FROM B3CONTRA b3lp
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = b3lp.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = b3lp.B1_PER_ID1
		AND bH.B1_PER_ID2 = b3lp.B1_PER_ID2	
		AND bH.B1_PER_ID3 = b3lp.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	WHERE
		2=2
		AND b3lp.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3lp.REC_STATUS = 'A'
		AND b3lp.B1_LICENSE_TYPE = 'Engineer'
		AND b3lp.B1_LICENSE_NBR = (
			SELECT
				MIN(b3lpS.B1_LICENSE_NBR)
			FROM B3CONTRA b3lpS
			WHERE
				2=2
				AND b3lpS.SERV_PROV_CODE = b3lp.SERV_PROV_CODE
				AND b3lpS.B1_PER_ID1 = b3lp.B1_PER_ID1
				AND b3lpS.B1_PER_ID2 = b3lp.B1_PER_ID2
				AND b3lpS.B1_PER_ID3 = b3lp.B1_PER_ID3
				AND b3lpS.REC_STATUS = b3lp.REC_STATUS
				AND b3lpS.B1_LICENSE_TYPE = 'Engineer'
				AND COALESCE(b3lpS.B1_PRINT_FLAG,'N') = (
					SELECT
						MAX(COALESCE(b3lpS2.B1_PRINT_FLAG,'N'))
					FROM B3CONTRA b3lpS2
					WHERE
						3=3
						AND b3lpS2.SERV_PROV_CODE = b3lpS.SERV_PROV_CODE
						AND b3lpS2.B1_PER_ID1 = b3lpS.B1_PER_ID1
						AND b3lpS2.B1_PER_ID2 = b3lpS.B1_PER_ID2
						AND b3lpS2.B1_PER_ID3 = b3lpS.B1_PER_ID3
						AND b3lpS2.REC_STATUS = b3lpS.REC_STATUS
						AND b3lpS2.B1_LICENSE_TYPE = 'Engineer'
					)
				)
			) eng ON
	b.SERV_PROV_CODE = eng.SERV_PROV_CODE
	AND b.B1_PER_ID1 = eng.B1_PER_ID1
	AND b.B1_PER_ID2 = eng.B1_PER_ID2
	AND b.B1_PER_ID3 = eng.B1_PER_ID3	
LEFT OUTER JOIN (
	SELECT
		b3lp.SERV_PROV_CODE
		,b3lp.B1_PER_ID1
		,b3lp.B1_PER_ID2
		,b3lp.B1_PER_ID3
		,b3lp.B1_LICENSE_NBR
		,b3lp.B1_LICENSE_TYPE
		,b3lp.B1_LIC_EXPIR_DD
		,b3lp.B1_BUS_NAME
		,b3lp.B1_CAE_FNAME
		,b3lp.B1_CAE_LNAME
		,b3lp.B1_ADDRESS1
		,b3lp.B1_ADDRESS2
		,b3lp.B1_ADDRESS3
		,b3lp.B1_CITY
		,b3lp.B1_STATE
		,b3lp.B1_ZIP
		,b3lp.B1_PHONE1
		,b3lp.B1_PHONE2
		,b3lp.B1_FAX
		,b3lp.B1_EMAIL
		,rsl.LIC_SEQ_NBR
	FROM B3CONTRA b3lp
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = b3lp.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = b3lp.B1_PER_ID1
		AND bH.B1_PER_ID2 = b3lp.B1_PER_ID2	
		AND bH.B1_PER_ID3 = b3lp.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	INNER JOIN RSTATE_LIC rsl ON
		b3lp.SERV_PROV_CODE = rsl.SERV_PROV_CODE
		AND b3lp.REC_STATUS = rsl.REC_STATUS
		AND b3lp.B1_LICENSE_TYPE = rsl.LIC_TYPE
		AND b3lp.B1_LICENSE_NBR = rsl.LIC_NBR
	WHERE
		2=2
		AND b3lp.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3lp.REC_STATUS = 'A'
		AND b3lp.B1_LICENSE_TYPE = 'Contractor'
		AND b3lp.B1_LICENSE_NBR = (
			SELECT
				MIN(b3lpS.B1_LICENSE_NBR)
			FROM B3CONTRA b3lpS
			WHERE
				2=2
				AND b3lpS.SERV_PROV_CODE = b3lp.SERV_PROV_CODE
				AND b3lpS.B1_PER_ID1 = b3lp.B1_PER_ID1
				AND b3lpS.B1_PER_ID2 = b3lp.B1_PER_ID2
				AND b3lpS.B1_PER_ID3 = b3lp.B1_PER_ID3
				AND b3lpS.REC_STATUS = b3lp.REC_STATUS
				AND b3lpS.B1_LICENSE_TYPE = 'Contractor'
				AND COALESCE(b3lpS.B1_PRINT_FLAG,'N') = (
					SELECT
						MAX(COALESCE(b3lpS2.B1_PRINT_FLAG,'N'))
					FROM B3CONTRA b3lpS2
					WHERE
						3=3
						AND b3lpS2.SERV_PROV_CODE = b3lpS.SERV_PROV_CODE
						AND b3lpS2.B1_PER_ID1 = b3lpS.B1_PER_ID1
						AND b3lpS2.B1_PER_ID2 = b3lpS.B1_PER_ID2
						AND b3lpS2.B1_PER_ID3 = b3lpS.B1_PER_ID3
						AND b3lpS2.REC_STATUS = b3lpS.REC_STATUS
						AND b3lpS2.B1_LICENSE_TYPE = 'Contractor'
					)
				)
			) contra ON
	b.SERV_PROV_CODE = contra.SERV_PROV_CODE
	AND b.B1_PER_ID1 = contra.B1_PER_ID1
	AND b.B1_PER_ID2 = contra.B1_PER_ID2
	AND b.B1_PER_ID3 = contra.B1_PER_ID3
	LEFT OUTER JOIN (
		SELECT
			g3atr.SERV_PROV_CODE
			,g3atr.G1_CONTACT_NBR
			,g3atr.G1_ATTRIBUTE_NAME
			,g3atr.G1_ATTRIBUTE_VALUE
		FROM G3CONTACT_ATTRIBUTE g3atr
		WHERE
			2=2
			AND g3atr.SERV_PROV_CODE = 'SANTACLARITA'
			AND g3atr.REC_STATUS = 'A'
			AND g3atr.G1_CONTACT_TYPE = 'Contractor'
			AND g3atr.G1_ATTRIBUTE_NAME IN ('WC CO NAME','WC AGENT NAME','WC AGENT PHONE','WC POLICY NO'
				,'WC EXP DATE')
			) a
	PIVOT(
		MAX(G1_ATTRIBUTE_VALUE)
		FOR G1_ATTRIBUTE_NAME IN ('WC CO NAME' AS wcCoNam,'WC AGENT NAME' AS wcAgntNam
			,'WC AGENT PHONE NUMBER' as wcAgntPhn,'WC POLICY NO' AS wcPolicyNbr,'WC EXP DATE' AS wcExpDate)
		) g3atrV ON
		contra.SERV_PROV_CODE = g3atrV.SERV_PROV_CODE
		AND contra.LIC_SEQ_NBR = g3atrV.G1_CONTACT_NBR
	LEFT OUTER JOIN(
		SELECT
			g3a1.SERV_PROV_CODE
			,g3a1.G1_CONTACT_NBR
			,COUNT(NULLIF(g3a1.G1_ATTRIBUTE_VALUE,'')) classCodeCnt
		FROM G3CONTACT_ATTRIBUTE g3a1
		WHERE
			2=2
			AND g3a1.SERV_PROV_CODE = 'SANTACLARITA'
			AND g3a1.REC_STATUS = 'A'
			AND g3a1.G1_CONTACT_TYPE = 'Contractor'
			AND g3a1.G1_ATTRIBUTE_NAME IN ('CLASS CODE 1','CLASS CODE 2','CLASS CODE 3','CLASS CODE 4')
		GROUP BY
			g3a1.SERV_PROV_CODE
			,g3a1.G1_CONTACT_NBR	
			) clsCnt ON
		contra.SERV_PROV_CODE = clsCnt.SERV_PROV_CODE
		AND contra.LIC_SEQ_NBR = clsCnt.G1_CONTACT_NBR
	LEFT OUTER JOIN G3CONTACT_ATTRIBUTE g3at ON
		contra.SERV_PROV_CODE = g3at.SERV_PROV_CODE
		AND contra.LIC_SEQ_NBR = g3at.G1_CONTACT_NBR
		AND g3at.G1_CONTACT_TYPE = 'Contractor'
		AND g3at.G1_ATTRIBUTE_VALUE = 'CLASS CODE 1'	
LEFT OUTER JOIN (
	SELECT
		b3cC.SERV_PROV_CODE
		,b3cC.B1_PER_ID1
		,b3cC.B1_PER_ID2
		,b3cC.B1_PER_ID3
		,COALESCE(b3cC.B1_FULL_NAME,(b3cC.B1_FNAME||' '||b3cC.B1_LNAME)) fullName
		,b3cC.B1_BUSINESS_NAME busName
	FROM B3CONTACT b3cC
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = b3cC.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = b3cC.B1_PER_ID1
		AND bH.B1_PER_ID2 = b3cC.B1_PER_ID2	
		AND bH.B1_PER_ID3 = b3cC.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	WHERE
		2=2
		AND b3cC.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3cC.REC_STATUS = 'A'
		AND b3cC.B1_CONTACT_TYPE = 'Tenant'
		AND b3cC.B1_CONTACT_NBR = (
			SELECT
				MAX(b3cCS.B1_CONTACT_NBR)
			FROM B3CONTACT b3cCS
			WHERE
				3=3
				AND b3cCS.SERV_PROV_CODE = b3cC.SERV_PROV_CODE
				AND b3cCS.B1_PER_ID1 = b3cC.B1_PER_ID1
				AND b3cCS.B1_PER_ID2 = b3cC.B1_PER_ID2
				AND b3cCS.B1_PER_ID3 = b3cC.B1_PER_ID3
				AND b3cCS.REC_STATUS = b3cC.REC_STATUS
				AND b3cCS.B1_CONTACT_TYPE = 'Tenant'
				AND COALESCE(b3cCS.B1_FLAG,'N') = ( 
					SELECT
						MAX(COALESCE(b3cCS2.B1_FLAG,'N'))
					FROM B3CONTACT b3cCS2
					WHERE
						4=4
						AND b3cCS2.SERV_PROV_CODE = b3cCS.SERV_PROV_CODE
						AND b3cCS2.B1_PER_ID1 = b3cCS.B1_PER_ID1
						AND b3cCS2.B1_PER_ID2 = b3cCS.B1_PER_ID2
						AND b3cCS2.B1_PER_ID3 = b3cCS.B1_PER_ID3
						AND b3cCS2.REC_STATUS = b3cCS.REC_STATUS
						AND b3cCS2.B1_CONTACT_TYPE = 'Tentant'
				)
		)
) b3c ON
	b.SERV_PROV_CODE = b3c.SERV_PROV_CODE
	AND b.B1_PER_ID1 = b3c.B1_PER_ID1
	AND b.B1_PER_ID2 = b3c.B1_PER_ID2
	AND b.B1_PER_ID3 = b3c.B1_PER_ID3	
LEFT OUTER JOIN (
	SELECT
		b3a.SERV_PROV_CODE
		,b3a.B1_PER_ID1
		,b3a.B1_PER_ID2
		,b3a.B1_PER_ID3
		,b3a.B1_HSE_NBR_START
		,b3a.B1_STR_DIR
		,b3a.B1_STR_NAME
		,b3a.B1_STR_SUFFIX
		,b3a.B1_UNIT_START
		,b3a.B1_UNIT_TYPE
		,b3a.B1_SITUS_CITY
		,b3a.B1_SITUS_STATE
		,b3a.B1_SITUS_ZIP
	FROM B3ADDRES b3a
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = b3a.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = b3a.B1_PER_ID1
		AND bH.B1_PER_ID2 = b3a.B1_PER_ID2	
		AND bH.B1_PER_ID3 = b3a.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	WHERE
		2=2
		AND b3a.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3a.REC_STATUS = 'A'
		AND b3a.B1_ADDRESS_NBR = (
			SELECT
				MIN(b3aS.B1_ADDRESS_NBR)
			FROM B3ADDRES b3aS
			WHERE
				3=3
				AND b3aS.SERV_PROV_CODE = b3a.SERV_PROV_CODE
				AND b3aS.B1_PER_ID1 = b3a.B1_PER_ID1
				AND b3aS.B1_PER_ID2 = b3a.B1_PER_ID2
				AND b3aS.B1_PER_ID3 = b3a.B1_PER_ID3
				AND b3aS.REC_STATUS = b3a.REC_STATUS
				AND COALESCE(b3aS.B1_PRIMARY_ADDR_FLG,'N') = (
					SELECT
						MAX(COALESCE(b3aS2.B1_PRIMARY_ADDR_FLG,'N'))
					FROM B3ADDRES b3aS2
					WHERE
						4=4
						AND b3aS2.SERV_PROV_CODE = b3aS.SERV_PROV_CODE
						AND b3aS2.B1_PER_ID1 = b3aS.B1_PER_ID1
						AND b3aS2.B1_PER_ID2 = b3aS.B1_PER_ID2
						AND b3aS2.B1_PER_ID3 = b3aS.B1_PER_ID3
						AND b3aS2.REC_STATUS = b3aS.REC_STATUS
				)
			)
		) b3aV ON
	b.SERV_PROV_CODE = b3aV.SERV_PROV_CODE
	AND b.B1_PER_ID1 = b3aV.B1_PER_ID1
	AND b.B1_PER_ID2 = b3aV.B1_PER_ID2
	AND b.B1_PER_ID3 = b3aV.B1_PER_ID3 
--B3PARCEL
LEFT OUTER JOIN (
	SELECT
		b3p.SERV_PROV_CODE
		,b3p.B1_PER_ID1
		,b3p.B1_PER_ID2
		,b3p.B1_PER_ID3
		,b3p.B1_LEGAL_DESC
		,b3p.B1_PARCEL_NBR
		,b3p.B1_LOT
		,b3p.B1_TRACT
	FROM B3PARCEL b3p
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = b3p.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = b3p.B1_PER_ID1
		AND bH.B1_PER_ID2 = b3p.B1_PER_ID2	
		AND bH.B1_PER_ID3 = b3p.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	WHERE
		2=2
		AND b3p.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3p.REC_STATUS = 'A'
		AND b3p.B1_PARCEL_NBR = (
		SELECT
			MIN(b3pS.B1_PARCEL_NBR)
		FROM B3PARCEL b3pS
		WHERE
			3=3
			AND b3pS.SERV_PROV_CODE = b3p.SERV_PROV_CODE
			AND b3pS.B1_PER_ID1 = b3p.B1_PER_ID1
			AND b3pS.B1_PER_ID2 = b3p.B1_PER_ID2
			AND b3pS.B1_PER_ID3 = b3p.B1_PER_ID3
			AND b3pS.REC_STATUS = b3p.REC_STATUS
			AND COALESCE(b3pS.B1_PRIMARY_PAR_FLG,'N') = (
				SELECT
					MAX(COALESCE(b3pS2.B1_PRIMARY_PAR_FLG,'N'))
				FROM B3PARCEL b3pS2
				WHERE
					4=4
					AND b3pS2.SERV_PROV_CODE = b3pS.SERV_PROV_CODE
					AND b3pS2.B1_PER_ID1 = b3pS.B1_PER_ID1
					AND b3pS2.B1_PER_ID2 = b3pS.B1_PER_ID2
					AND b3pS2.B1_PER_ID3 = b3pS.B1_PER_ID3
					AND b3pS2.REC_STATUS = b3pS.REC_STATUS
				)
			)
		) b3pV ON
	b.SERV_PROV_CODE = b3pV.SERV_PROV_CODE
	AND b.B1_PER_ID1 = b3pV.B1_PER_ID1
	AND b.B1_PER_ID2 = b3pV.B1_PER_ID2
	AND b.B1_PER_ID3 = b3pV.B1_PER_ID3
LEFT OUTER JOIN (
	SELECT
		b5.SERV_PROV_CODE
		,b5.B1_PER_ID1
		,b5.B1_PER_ID2
		,b5.B1_PER_ID3
		,COALESCE(b3o.B1_OWNER_FULL_NAME,b3o.B1_OWNER_FNAME||' '||b3o.B1_OWNER_LNAME) ownerName
		,b3o.B1_MAIL_ADDRESS1 addr1
		,CASE WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL THEN b3o.B1_MAIL_ADDRESS2
			ELSE LTRIM(RTRIM(b3o.B1_MAIL_CITY))||', '||b3o.B1_MAIL_STATE||' '||b3o.B1_MAIL_ZIP
		END AS addr2
		,CASE WHEN NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL THEN NULL
		WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL 
			AND NOT NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL
			THEN b3o.B1_MAIL_ADDRESS3
		WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL 
			AND NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL
			THEN LTRIM(RTRIM(b3o.B1_MAIL_CITY))||', '||b3o.B1_MAIL_STATE||' '||b3o.B1_MAIL_ZIP
		WHEN NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL 
			AND NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL THEN NULL
		END AS addr3	
		,CASE WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL
			THEN LTRIM(RTRIM(b3o.B1_MAIL_CITY))||', '||b3o.B1_MAIL_STATE||' '||b3o.B1_MAIL_ZIP
		ELSE NULL END AS addr4
		,COALESCE(b3o.B1_PHONE,'No Phone') phone
		,b3o.B1_EMAIL email
	FROM B1PERMIT b5
	INNER JOIN B3OWNERS b3o ON
		b5.SERV_PROV_CODE = b3o.SERV_PROV_CODE
		AND b5.B1_PER_ID1 = b3o.B1_PER_ID1
		AND b5.B1_PER_ID2 = b3o.B1_PER_ID2
		AND b5.B1_PER_ID3 = b3o.B1_PER_ID3
		AND b5.REC_STATUS = b3o.REC_STATUS
	WHERE
		2=2
		AND b5.SERV_PROV_CODE = 'SANTACLARITA'
		AND b5.B1_PER_GROUP = 'Building'
		AND b5.B1_PER_TYPE IN ('MEP','Permit')
		AND b5.REC_STATUS = 'A'
		AND b3o.B1_OWNER_NBR = (
			SELECT
				MIN(b3oS.B1_OWNER_NBR)
			FROM B3OWNERS b3oS
			WHERE
				3=3
				AND b3oS.SERV_PROV_CODE = b3o.SERV_PROV_CODE
				AND b3oS.B1_PER_ID1 = b3o.B1_PER_ID1
				AND b3oS.B1_PER_ID2 = b3o.B1_PER_ID2
				AND b3oS.B1_PER_ID3 = b3o.B1_PER_ID3
				AND b3oS.REC_STATUS = b3o.REC_STATUS
				AND COALESCE(b3oS.B1_PRIMARY_OWNER,'N') = (
					SELECT
						MAX(COALESCE(b3oS2.B1_PRIMARY_OWNER,'N'))
					FROM B3OWNERS b3oS2
					WHERE
						4=4
						AND b3oS2.SERV_PROV_CODE = b3oS.SERV_PROV_CODE
						AND b3oS2.B1_PER_ID1 = b3oS.B1_PER_ID1
						AND b3oS2.B1_PER_ID2 = b3oS.B1_PER_ID2
						AND b3oS2.B1_PER_ID3 = b3oS.B1_PER_ID3
						AND b3oS2.REC_STATUS = b3oS.REC_STATUS
					)
				)
	) owner ON
	b.SERV_PROV_CODE = owner.SERV_PROV_CODE
	AND b.B1_PER_ID1 = owner.B1_PER_ID1
	AND b.B1_PER_ID2 = owner.B1_PER_ID2
	AND b.B1_PER_ID3 = owner.B1_PER_ID3
LEFT OUTER JOIN (
	SELECT
		bc1.SERV_PROV_CODE
		,bc1.B1_PER_ID1
		,bc1.B1_PER_ID2
		,bc1.B1_PER_ID3
		,bc1.B1_CHECKBOX_DESC
		,bc1.B1_CHECKLIST_COMMENT
	FROM BCHCKBOX bc1
	INNER JOIN B1PERMIT bH ON
		bH.SERV_PROV_CODE = bc1.SERV_PROV_CODE
		AND bH.B1_PER_ID1 = bc1.B1_PER_ID1
		AND bH.B1_PER_ID2 = bc1.B1_PER_ID2	
		AND bH.B1_PER_ID3 = bc1.B1_PER_ID3
		AND bH.B1_PER_GROUP = 'Building'
		AND bH.B1_PER_TYPE IN ('MEP','Permit')
	WHERE
		1=1
		AND bc1.REC_STATUS = 'A'
		AND bc1.B1_CHECKBOX_TYPE IN ('PROJECT INFORMATION','BUILDING INFO','OFFICE USE ONLY') --ASI SUBGROUP
		AND bc1.B1_CHECKBOX_DESC IN ('Type of Construction','Use Group','Use Detail'
			,'Structure Type','Number of Stories','Total Square Footage','Applicable Code'
			,'Building-Use Restrictions','Project Notes') --ASI FIELD LABEL
	) a
PIVOT(
	MAX(B1_CHECKLIST_COMMENT)
	FOR B1_CHECKBOX_DESC IN ('Type of Construction' AS consType
				,'Use Group' AS useGrp,'Use Detail' AS useDetl,'Structure Type' AS structType
				,'Number of Stories' AS nbrStrs,'Total Square Footage' AS totSqFoot
				,'Applicable Code' AS applCode,'Building-Use Restrictions' AS useRestr
				,'Project Notes' AS projNotes) --REPEAT FIELD LABELS IN QUOTES, ADD ALIAS'
)asiPiv ON
	b.SERV_PROV_CODE = asiPiv.SERV_PROV_CODE
	AND b.B1_PER_ID1 = asiPiv.B1_PER_ID1
	AND b.B1_PER_ID2 = asiPiv.B1_PER_ID2
	AND b.B1_PER_ID3 = asiPiv.B1_PER_ID3
LEFT OUTER JOIN SETDETAILS sd ON
	b.SERV_PROV_CODE = sd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = sd.B1_PER_ID1	
	AND b.B1_PER_ID2 = sd.B1_PER_ID2
	AND b.B1_PER_ID3 = sd.B1_PER_ID3
	AND sd.SET_ID = '{setId}'
--WORKFLOW	
LEFT OUTER JOIN GPROCESS gp1 ON
	b.SERV_PROV_CODE = gp1.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp1.B1_PER_ID1	
	AND b.B1_PER_ID2 = gp1.B1_PER_ID2
	AND b.B1_PER_ID3 = gp1.B1_PER_ID3
	AND b.REC_STATUS = gp1.REC_STATUS
	AND gp1.SD_PRO_DES = 'Permit Issuance'
	AND gp1.SD_APP_DES = 'Issued'
LEFT OUTER JOIN GPROCESS gp2 ON
	b.SERV_PROV_CODE = gp2.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp2.B1_PER_ID1	
	AND b.B1_PER_ID2 = gp2.B1_PER_ID2
	AND b.B1_PER_ID3 = gp2.B1_PER_ID3
	AND b.REC_STATUS = gp2.REC_STATUS
	AND gp2.SD_PRO_DES = 'Plans Review Consolidation'
	AND gp2.SD_APP_DES = 'Approved'
LEFT OUTER JOIN GPROCESS gp3 ON
	b.SERV_PROV_CODE = gp3.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp3.B1_PER_ID1	
	AND b.B1_PER_ID2 = gp3.B1_PER_ID2
	AND b.B1_PER_ID3 = gp3.B1_PER_ID3
	AND b.REC_STATUS = gp3.REC_STATUS
	AND gp3.SD_PRO_DES = 'Inspections'
	AND gp3.SD_APP_DES = 'Complete'
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Building'
	AND b.B1_PER_TYPE IN ('MEP','Permit')
	AND b.B1_PER_SUB_TYPE = 'NA'
	AND b.B1_PER_CATEGORY = 'NA'
	AND (
			(
				b.B1_ALT_ID = '{?altId}'
				AND '{?setId}' IS NULL
			)
		OR
			(
				'{?altId}' IS NULL
				AND sd.SET_ID = '{?setId}'
			)
		)