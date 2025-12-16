import yaml
import yfinance as yf
import pandas as pd
import os
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_yaml_config(filename):
    """Helper to load YAML files from the same directory as this script."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, filename)
    try:
        with open(file_path, 'r') as file:
            return yaml.safe_load(file)
    except FileNotFoundError:
        logging.error(f"Configuration file not found: {file_path}")
        raise

def get_industry_tickers(industry_keyword: str) -> list:
    """
    Parses industry keyword and returns matching tickers from industry_pool.yaml.
    Performs case-insensitive fuzzy matching.
    """
    pool_config = load_yaml_config('industry_pool.yaml')
    
    keyword_lower = industry_keyword.lower().strip()
    matched_key = None
    
    # Exact match check first
    if keyword_lower in pool_config:
        matched_key = keyword_lower
    else:
        # Fuzzy/Partial match
        for key in pool_config.keys():
            if keyword_lower in key.lower() or key.lower() in keyword_lower:
                matched_key = key
                break
    
    if matched_key:
        logging.info(f"Matched industry '{matched_key}' for keyword '{industry_keyword}'")
        return pool_config[matched_key]
    else:
        available_industries = list(pool_config.keys())
        raise ValueError(f"No matching industry found for '{industry_keyword}'. Available: {available_industries}")

def fetch_snapshot_data(ticker_list: list) -> pd.DataFrame:
    """
    Fetches snapshot data for a list of tickers using yfinance.
    Returns a DataFrame with columns: current_price, market_cap, revenue_growth_yoy, gross_margin, trailing_pe, beta.
    """
    data = []
    logging.info(f"Fetching data for {len(ticker_list)} tickers...")
    
    # Using yf.Tickers for batch processing where possible, but accessing info individually for reliability
    tickers = yf.Tickers(' '.join(ticker_list))
    
    for ticker_symbol in ticker_list:
        try:
            ticker = tickers.tickers[ticker_symbol]
            info = ticker.info
            
            # Extract data with safe defaults or None
            # Market cap in Billions
            market_cap = info.get('marketCap')
            market_cap_b = market_cap / 1e9 if market_cap else None
            
            # Revenue Growth (quarterly usually)
            rev_growth = info.get('revenueGrowth')
            
            # Gross Margin
            gross_margin = info.get('grossMargins')
            
            # Trailing PE
            trailing_pe = info.get('trailingPE')
            
            # Beta
            beta = info.get('beta')
            
            current_price = info.get('currentPrice') or info.get('regularMarketPrice')

            data.append({
                'ticker': ticker_symbol,
                'current_price': current_price,
                'market_cap': market_cap_b,
                'revenue_growth_yoy': rev_growth,
                'gross_margin': gross_margin,
                'trailing_pe': trailing_pe,
                'beta': beta
            })
            
            # Rate limiting to be polite
            time.sleep(0.2) 
            
        except Exception as e:
            logging.warning(f"Failed to fetch data for {ticker_symbol}: {e}")
            continue

    df = pd.DataFrame(data)
    if not df.empty:
        df.set_index('ticker', inplace=True)
    return df

def apply_screen(df_snapshot: pd.DataFrame, screen_name='growth_tech_screen') -> pd.DataFrame:
    """
    Applies screening rules from screening_rules.yaml to the DataFrame.
    """
    rules_config = load_yaml_config('screening_rules.yaml')
    
    if screen_name not in rules_config:
        raise ValueError(f"Screening rule '{screen_name}' not found in configuration.")
    
    rules = rules_config[screen_name]
    logging.info(f"Applying screen '{screen_name}' with rules: {rules}")
    
    df_filtered = df_snapshot.copy()
    
    # Apply filters
    if 'market_cap_min' in rules:
        df_filtered = df_filtered[df_filtered['market_cap'] >= rules['market_cap_min']]
        
    if 'revenue_growth_yoy_min' in rules:
        df_filtered = df_filtered[df_filtered['revenue_growth_yoy'] >= rules['revenue_growth_yoy_min']]
        
    if 'gross_margin_min' in rules:
        df_filtered = df_filtered[df_filtered['gross_margin'] >= rules['gross_margin_min']]
        
    if 'pe_max' in rules:
        # Filter out None PEs or PEs above max. 
        # Note: Companies with negative earnings often have None PE in yfinance or negative.
        # We keep rows where PE is not null AND PE <= max
        df_filtered = df_filtered[df_filtered['trailing_pe'].notna() & (df_filtered['trailing_pe'] <= rules['pe_max'])]
        
    if 'beta_max' in rules:
        df_filtered = df_filtered[df_filtered['beta'] <= rules['beta_max']]

    return df_filtered

def run_screen(industry_keyword: str) -> dict:
    """
    Main entry point. Orchestrates the screening process.
    """
    try:
        # 1. Parse Industry
        tickers = get_industry_tickers(industry_keyword)
        matched_industry = industry_keyword # Simplified, ideally we'd return the key from get_industry_tickers
        
        # 2. Fetch Data
        df_snapshot = fetch_snapshot_data(tickers)
        
        if df_snapshot.empty:
            return {
                'industry_matched': matched_industry,
                'error': "No data fetched for tickers."
            }

        # 3. Apply Rules
        # Determine which rule to apply? Defaulting to growth_tech_screen as per instructions
        screen_name = 'growth_tech_screen'
        df_filtered = apply_screen(df_snapshot, screen_name)
        
        # 4. Format Output
        result = {
            'industry_matched': matched_industry,
            'original_tickers': tickers,
            'snapshot_data': df_snapshot, # Note: DataFrame objects might need serialization for JSON APIs
            'filtered_tickers': df_filtered.index.tolist(),
            'filtered_data': df_filtered,
            'screening_rules_applied': load_yaml_config('screening_rules.yaml')[screen_name]
        }
        
        return result
        
    except Exception as e:
        logging.error(f"Screening failed: {e}")
        return {'error': str(e)}

if __name__ == "__main__":
    # Simple CLI test
    import sys
    keyword = sys.argv[1] if len(sys.argv) > 1 else "semi"
    print(f"Running screen for: {keyword}")
    results = run_screen(keyword)
    
    if 'filtered_data' in results:
        print("\n--- Filtered Results ---")
        print(results['filtered_data'])
    else:
        print("\nError or No Results:")
        print(results)
