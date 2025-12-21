import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const API_KEY = 'T2YL43ZJDEVJZDCP'; // User provided key

serve(async (req) => {
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { symbol, endpoint } = await req.json()
    
    if (!symbol) {
      return new Response(
        JSON.stringify({ error: 'Symbol is required' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    let func = '';
    if (endpoint === 'overview') {
      func = 'OVERVIEW';
    } else if (endpoint === 'quote') {
      func = 'GLOBAL_QUOTE';
    } else {
      return new Response(
        JSON.stringify({ error: 'Invalid endpoint. Use "overview" or "quote"' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    const url = `https://www.alphavantage.co/query?function=${func}&symbol=${symbol}&apikey=${API_KEY}`;
    console.log(`Fetching ${func} for ${symbol}...`);

    const apiResponse = await fetch(url);
    const data = await apiResponse.json();

    console.log(`Alpha Vantage Response:`, JSON.stringify(data).substring(0, 200)); // Log start of response

    return new Response(
      JSON.stringify(data),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
