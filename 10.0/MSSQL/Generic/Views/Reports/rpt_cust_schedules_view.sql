
 
 / * * * * * *   O b j e c t :     V i e w   [ d b o ] . [ r p t _ c u s t _ s c h e d u l e s _ v i e w ]         S c r i p t   D a t e :   0 3 / 2 4 / 2 0 0 9   0 8 : 1 4 : 2 8   * * * * * * / 
 
 S E T   A N S I _ N U L L S   O N 
 
 G O 
 
 S E T   Q U O T E D _ I D E N T I F I E R   O F F 
 
 G O 
 
 
 c r e a t e   v i e w   [ d b o ] . [ r p t _ c u s t _ s c h e d u l e s _ v i e w ]   a s 
 
 s e l e c t   b e . e l e m e n t k e y , 
 
 b e . b o o k k e y   b o o k k e y ,   d . d a t e t y p e c o d e , e . e l e m e n t t y p e c o d e ,   e . e l e m e n t n a m e , d . d e s c r i p t i o n   d a t e n a m e l o n g , 
 
 d . d a t e l a b e l   d a t e n a m e m e d i u m ,   d . d a t e l a b e l s h o r t   d a t e n a m e s h o r t , 
 
 t . e s t i m a t e d d a t e   e s t i i m a t e d d a t e ,   t . a c t u a l d a t e   a c t u a l d a t e , t . s o r t o r d e r   t a s k s o r t o r d e r , 
 
 t . d u r a t i o n   t a s k d u r a t i o n , t . t a s k n o t e ,   t . l a s t u s e r i d ,   t . l a s t m a i n t d a t e 
 
 f r o m   
 
 e l e m e n t   e , 
 
 b o o k e l e m e n t   b e , 
 
 t a s k   t , 
 
 d a t e t y p e   d 
 
 w h e r e   b e . e l e m e n t k e y   =   e . e l e m e n t k e y 
 
 - - a n d   e . e l e m e n t t y p e c o d e = 2 1 
 
 a n d   e . e l e m e n t k e y   =   t . e l e m e n t k e y 
 
 a n d   d . d a t e t y p e c o d e = t . d a t e t y p e c o d e 
 
 