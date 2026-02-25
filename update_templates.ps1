# Script to update all HTML templates for Flask
# This updates script/style paths and adds Flask url_for

Get-ChildItem "c:\Users\91636\Downloads\PLACEMENT CELL\templates\*.html" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Update script src paths to use Flask static folder
    $content = $content -replace 'src="js/', 'src="{{ url_for(''static'', filename=''js/'
    $content = $content -replace '\.js"', '.js'') }}"'
    
    # Update .html links to use Flask url_for
    $content = $content -replace "href='([^']+)\.html'", "href=""{{ url_for('`$1') }}"""
    $content = $content -replace 'href="([^"]+)\.html"', 'href="{{ url_for(''$1'') }}"'
    $content = $content -replace "window\.location\.href='([^']+)\.html'", "window.location.href='{{ url_for('`$1') }}'"
    $content = $content -replace 'window\.location\.href="([^"]+)\.html"', 'window.location.href="{{ url_for(''$1'') }}"'
    
    # Remove Supabase script tag (no longer needed on client side for auth)
    $content = $content -replace '<script src="https://cdn\.jsdelivr\.net/npm/@supabase/supabase-js"></script>', ''
    
    # Remove session.js imports
    $content = $content -replace '<script type="module" src=".*session\.js"></script>', ''
    
    Set-Content -Path $_.FullName -Value $content
    Write-Host "Updated: $($_.Name)"
}

Write-Host "`nAll templates updated for Flask!"
