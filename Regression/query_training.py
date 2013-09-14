import dbutil
import os

CODE_DIR       = r'C:\CODE'
REGRESSION_DIR = os.path.join(CODE_DIR, r'classes\comp540\code\regression')
QUERY_FILE     = os.path.join(REGRESSION_DIR, 'training_data.sql')
DB_HOST        = 'LOCALHOST'
OUT_FILE       = os.path.join(REGRESSION_DIR, 'training_data.csv')
OUT_DELIMITER  = ','
HEADER_ROW     = True
CONVERT_CLASS  = False
COLUMN_NAMES   = (
  'mlsnum',
  'lat',
  'lon',
  'lot',
  'sqft',
  'landval',
  'landperft',
  'imprval',
  'imprperft',
  'appr',
  'defects',
  'defectsrprt',
  'foundation',
  'repaired',
  'treated',
  'yearbuilt',
  'protested',
  'a4',
  'a9inside',
  'a9outside',
  'a16',
  'a17',
  'a20',
  'a21',
  'a22',
  'distdt',
  'foreclose',
  'quicksale',
  'needsrepair',
  'salesprice')

dbutil.connect_db(
    DB_HOST,
    'dposada',
    'copperchair36',
    'real_estate')
queryf = open(QUERY_FILE, 'r')
sql    = queryf.read()
queryf.close()

outfile = open(OUT_FILE, 'w')
if HEADER_ROW:
    col_map = []
    for i in range(0,len(COLUMN_NAMES)):
        if i>0:
            outfile.write(OUT_DELIMITER)
        outfile.write(COLUMN_NAMES[i])
        col_map.append(COLUMN_NAMES[i])
    outfile.write('\n')
result    = dbutil.query(sql)
class_map = []
for record in result:
    values = list(record[0:len(record)-1])
    cls    = record[len(record)-1]
    if CONVERT_CLASS:    
        classid = -1
        if cls in class_map:
            classid = class_map.index(cls)
        else:
            class_map.append(cls)
            classid = len(class_map)-1
        values.append(classid+1)
    else:
        values.append(cls)

    line = OUT_DELIMITER.join(map((lambda v: str(v)), values))
    outfile.write(line + '\n')

outfile.close()
for i in range(0,len(class_map)):
    print str(i),':',class_map[i]
print ','.join(map((lambda v: "'"+v+"'"), class_map))
print ','.join(map((lambda v: "'"+v+"'"), COLUMN_NAMES))
print ','.join(map((lambda v: "'"+v+"'"), col_map))
