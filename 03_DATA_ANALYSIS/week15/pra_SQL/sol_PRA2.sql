------------------------------------------------------------------------------------------------

-- 
SET search_path TO erp;

------------------------------------------------------------------------------------------------
--
-- Consulta a) 
--
------------------------------------------------------------------------------------------------
SELECT cust_no, cust_name, cust_cif
FROM tb_customer
WHERE 1=1
AND cust_name LIKE 'AGR%'
ORDER BY cust_no DESC;
------------------------------------------------------------------------------------------------
--
-- Consulta b) 
--
------------------------------------------------------------------------------------------------
SELECT tc.cust_no, cust_name, site_address, site_city,
       invoice_no
FROM tb_customer tc,
     tb_site ts,
     tb_invoice ti
WHERE 1=1
AND tc.cust_no = ti.cust_no 
AND ts.site_id = ti.site_id
AND UPPER(ts.site_city) = 'GRANADA'
ORDER BY tc.cust_no, invoice_no DESC;

------------------------------------------------------------------------------------------------
--
-- Consulta c) 
--
------------------------------------------------------------------------------------------------



SELECT co_name, num_fac
FROM (
	SELECT tc.co_code, tc.co_name, COUNT(1) num_fac
	FROM tb_company tc,
		 tb_invoice ti
	WHERE 1=1
	AND tc.co_code = ti.co_code
	GROUP BY tc.co_code, tc.co_name
	ORDER BY 3 DESC
) as tabla_temp
WHERE num_fac = (SELECT MAX(x.num_fac)
				 FROM (SELECT tc.co_code, tc.co_name, COUNT(1) num_fac
	FROM tb_company tc,
		 tb_invoice ti
	WHERE 1=1
	AND tc.co_code = ti.co_code
	GROUP BY tc.co_code, tc.co_name) as x
);

-- Alternativa con LIMIT 1 con valores ordenados DESC
SELECT co_name, num_fac
FROM (
	SELECT tc.co_code, tc.co_name, COUNT(1) num_fac
	FROM tb_company tc,
		 tb_invoice ti
	WHERE 1=1
	AND tc.co_code = ti.co_code
	GROUP BY tc.co_code, tc.co_name
	ORDER BY 3 DESC
) as tabla_temp
LIMIT 1;


------------------------------------------------------------------------------------------------
--
-- Consulta d) 
--
------------------------------------------------------------------------------------------------

SELECT invoice_no, cust_name, co_name, num_fac
FROM (
    SELECT invoice_no, tc.cust_name, tco.co_name, COUNT(1) num_fac
    FROM erp.tb_invoice ti,
         erp.tb_lines tl,
         erp.tb_customer tc,
         erp.tb_company tco         
    WHERE 1=1
    AND ti.invoice_id = tl.invoice_id
    AND tc.cust_no    = ti.cust_no
    and ti.co_code    = tco.co_code
    GROUP BY invoice_no, tc.cust_name, tco.co_name
) f
WHERE 1=1
AND num_fac >18
ORDER BY num_fac DESC, co_name;

-- Alternativa

SELECT invoice_no, tc.cust_name, tco.co_name, COUNT(1) num_fac
    FROM erp.tb_invoice ti,
         erp.tb_lines tl,
         erp.tb_customer tc,
         erp.tb_company tco         
    WHERE 1=1
    AND ti.invoice_id = tl.invoice_id
    AND tc.cust_no    = ti.cust_no
    AND ti.co_code    = tco.co_code
    GROUP BY invoice_no, tc.cust_name, tco.co_name
    HAVING COUNT(1)>18
    ORDER BY num_fac ASC;

   --- OBSERVAR num
   
   SELECT
	iv.invoice_no num_factura
	,cu.cust_name nombre_cliente
	,co.co_name nombre_companya
	,COUNT(1) tot_numero_lineas
FROM erp.tb_customer cu
INNER JOIN erp.tb_invoice iv
ON iv.cust_no = cu.cust_no
INNER JOIN erp.tb_company co
ON co.co_code = iv.co_code
INNER JOIN erp.tb_lines li
ON li.invoice_id = iv.invoice_id
WHERE li.line_num > 18
GROUP BY nombre_cliente, nombre_companya, num_factura
ORDER BY
	tot_numero_lineas DESC
	,nombre_companya ASC;
	
------------------------------------------------------------------------------------------------
--
-- Consulta e) 
--
------------------------------------------------------------------------------------------------

SELECT tco.co_code, tco.co_name, tc.cust_no, tc.cust_name, 
       SUM(iva_amount) tot_iva, SUM(tot_amount) tot_amount
    FROM erp.tb_invoice ti,
         erp.tb_customer tc,
         erp.tb_company tco         
    WHERE 1=1
    AND tc.cust_no    = ti.cust_no
    AND ti.co_code    = tco.co_code
    AND payed = 'N'
    GROUP BY tco.co_code, tco.co_name, tc.cust_no, tc.cust_name
    ORDER BY tco.co_name, tc.cust_no DESC ;