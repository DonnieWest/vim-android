function! apk#bin()
  if exists('g:apkanalyzer_path')
    return g:apkanalyzer_path
  endif

  if executable('apkanalyzer')
    let g:apkanalyzer_path = 'apkanalyzer'
    return g:apkanalyzer_path
  endif
endfunction

function! s:findApplicationId()
  let l:apks = apk#getBuiltApks()

  return system(apk#bin() . ' manifest application-id ' . l:apks)
endfunction

function! apk#getApplicationId() abort
  return cache#get(gradle#key(gradle#findGradleFile()), 'applicationId', s:findApplicationId())
endfunction

function! s:findMainActivityId()
  let l:apks = apk#getBuiltApks()

  let l:buildString = apk#bin() . ' manifest print ' . s:chomp(l:apks) . " | xmlstarlet sel -t -c \"///activity[intent-filter/action[@android:name='android.intent.action.MAIN']]\" | xmlstarlet sel -t -c \"string(//*[local-name()='activity']/@android:name)\""

  echom l:buildString

  return s:chomp(system(l:buildString))

endfunction

function! apk#getMainActivityId() abort
  return cache#get(gradle#key(gradle#findGradleFile()), 'mainActivityId', s:findMainActivityId())
endfunction

function! apk#getBuiltApks()
  return s:chomp(system('find ./*/build/** -name "app-debug.apk"'))
endfunction

""
" Helper method to remove the end \r\n from a string.
function! s:chomp(str)
  let l:noreturn = substitute(copy(a:str), '^\n*\(.\{-}\)\n*$', '\1', '')
  return substitute(l:noreturn, '^\r*\(.\{-}\)\r*$', '\1', '')
endfunction
