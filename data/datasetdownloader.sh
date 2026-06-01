#!/bin/bash

# Download only NIFTY 50 minute data
kaggle datasets download debashis74017/nifty-50-minute-data \
  --file "NIFTY 50_minute.csv" \
  -p raw/

# Download NIFTY 50 daily
kaggle datasets download debashis74017/nifty-50-minute-data \
  --file "NIFTY 50_day.csv" \
  -p raw/

# Download NIFTY 50 5-minute
kaggle datasets download debashis74017/nifty-50-minute-data \
  --file "NIFTY 50_5minute.csv" \
  -p raw/

# Download India VIX daily
kaggle datasets download debashis74017/nifty-50-minute-data \
  --file "INDIA VIX_day.csv" \
  -p raw/
