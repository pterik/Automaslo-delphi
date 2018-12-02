INSERT INTO s_options (product_id, feature_id, value) 
 SELECT ID, 441 AS feature_id, UPPER(b.BRAND) FROM s_products , 
 (SELECT 'aral' AS brand UNION SELECT 'bizol' UNION SELECT 'bmw' UNION SELECT 'bp' UNION SELECT 'castrol'
UNION SELECT 'elf' UNION SELECT 'eneos' UNION SELECT 'evo' UNION SELECT 'febi' UNION SELECT 'ford'
UNION SELECT 'gm_opel' UNION SELECT 'honda' UNION SELECT 'japan_oil' UNION SELECT 'kroon' UNION
SELECT 'lexus' UNION SELECT 'liqui_moly' UNION SELECT 'mannol' UNION SELECT 'mazda' UNION SELECT 'mercedes'
UNION SELECT 'mitasu' UNION SELECT 'mitsubishi' UNION SELECT 'mobil1' UNION SELECT 'mobis' UNION SELECT 'motul'
UNION SELECT 'nissan' UNION SELECT 'pennasol' UNION SELECT 'shell' UNION SELECT 'subaru' UNION SELECT 'texaco'
UNION SELECT 'total' UNION SELECT 'toyota' UNION SELECT 'vag' UNION SELECT 'valvoline' UNION SELECT 'vatoil'
UNION SELECT 'yacco' UNION SELECT 'zic' ) b
WHERE UPPER(name) LIKE CONCAT(UPPER(BRAND), '%') 
AND ID NOT IN (SELECT product_id FROM s_options); 
COMMIT; 