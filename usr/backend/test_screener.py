import industry_screener as iscr
import pandas as pd

def test_run():
    print("Testing Industry Screener Module...")
    
    industry_keyword = "semiconductor"
    print(f"\n1. Input Keyword: {industry_keyword}")
    
    try:
        result = iscr.run_screen(industry_keyword)
        
        if 'error' in result:
            print(f"Error: {result['error']}")
            return

        print(f"\n2. Matched Industry: {result.get('industry_matched', 'Unknown')}")
        print(f"3. Original Tickers ({len(result['original_tickers'])}): {result['original_tickers']}")
        
        print(f"\n4. Snapshot Data (Head):")
        print(result['snapshot_data'].head())
        
        print(f"\n5. Screening Rules Applied:")
        print(result['screening_rules_applied'])
        
        print(f"\n6. Filtered Tickers ({len(result['filtered_tickers'])}): {result['filtered_tickers']}")
        
        print(f"\n7. Filtered Data Details:")
        print(result['filtered_data'])
        
        print("\nTest Complete.")
        
    except Exception as e:
        print(f"Test failed with exception: {e}")

if __name__ == "__main__":
    test_run()
