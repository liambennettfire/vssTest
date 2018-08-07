
-- Refactor the blue one
update gentables_ext 
set gentext1 = 'eLogo_blue.svg'
where gentext1 = 'elo-logo-select.png' 

-- Refactor the red one
update gentables_ext 
set gentext1 = 'EoD_Logo_E.svg'
where gentext1 = 'elo-logo.png' 

-- Refactor the black one
update gentables_ext 
set gentext1 = 'eLogo_black.svg'
where gentext1 = 'elo-logo-black.png' 

