CREATE KEYSPACE sams_p13n_static_uf WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};

USE sams_p13n_static_uf;

CREATE TABLE sams_p13n_static_uf.user_feature (
    id text PRIMARY KEY,
    created_date timestamp,
    data text,
    modified_date timestamp
);

INSERT INTO sams_p13n_static_uf.user_feature (id, data)
VALUES (
'MOCK_CID_GOLDEN_DATA_2_PPM',
'{"pbs":1,"ts":1720602704,"cid":"270a476560d54578917f4f2f5fb5030e","ct":3,"items":[{"ipi":24.0,"lpq":1.0,"tot_ord":7,"id":"231764404","g1":0.15842,"pb1":0.15842,"qP":1,"p":"9ANGQ2W68QRZ","src":1,"bvId":"231764404","ptc":"prod10830398","lpd":"20240707","b1":0.15842,"g2":0.15839,"ipi1":16.75,"g3":0.070629999}]}'
);
