#!/bin/bash

# Email configuration
TO="hesham.abouaisha@bmo.com"
CC="TESPEAdvancedDataPlatformEngineering_Hadoop@bmo.com"
SUBJECT="HDFS Report - $(date +%Y-%m-%d)"
REPORT="/tmp/hdfs_report.html"

# Collect HDFS metrics
FILES_DIRS=$(sudo -u hdfs hdfs dfs -count / | awk '{print $1}')
TOTAL_BLOCKS=$(sudo -u hdfs hdfs fsck / -files -blocks -locations 2>/dev/null | grep "Total blocks" | awk '{print $4}')
DFS_USED=$(sudo -u hdfs hdfs dfsadmin -report | grep "DFS Used:" | head -1 | awk '{print $3}')

# Generate HTML report
cat > $REPORT << EOF
<html>
<body>
<h2>HDFS Report - $(date +%Y-%m-%d)</h2>
<table border="1" cellpadding="10">
<tr><th>Metric</th><th>Value</th></tr>
<tr><td>Files and Directories</td><td>$FILES_DIRS</td></tr>
<tr><td>Total Blocks</td><td>$TOTAL_BLOCKS</td></tr>
<tr><td>DFS Used</td><td>$DFS_USED</td></tr>
</table>
</body>
</html>
EOF

# Send email
cat $REPORT | mail -s "$(echo -e "$SUBJECT\nContent-Type: text/html")" -c $CC $TO

if [ $? -eq 0 ]; then
  echo "Report sent to $TO"
else
  echo "Error sending email. Report saved at: $REPORT"
fi