FasdUAS 1.101.10   ��   ��    k             l     ��  ��    B < Define the path to the Pages file and the output movie file     � 	 	 x   D e f i n e   t h e   p a t h   t o   t h e   P a g e s   f i l e   a n d   t h e   o u t p u t   m o v i e   f i l e   
  
 l     ����  r         m        �   N . / D o c s / A p p l i c a t i o n V i e w C o n t r o l l e r H . p a g e s  o      ���� 0 pagesfilepath pagesFilePath��  ��        l     ��������  ��  ��        l     ��  ��    = 7 Create a temporary directory to store extracted images     �   n   C r e a t e   a   t e m p o r a r y   d i r e c t o r y   t o   s t o r e   e x t r a c t e d   i m a g e s      l   	 ����  I   	�� ��
�� .sysoexecTEXT���     TEXT  m       �   B m k d i r   - p   ~ / m a k e M o v i e / p a g e s _ i m a g e s��  ��  ��        l     ��������  ��  ��       !   l     ��������  ��  ��   !  " # " l  
  $���� $ r   
  % & % m   
  ' ' � ( ( > ~ / m a k e M o v i e / s y s t e m E v o l u t i o n . m p 4 & o      ���� "0 outputmoviepath outputMoviePath��  ��   #  ) * ) l     ��������  ��  ��   *  + , + l     �� - .��   - 5 / Function to extract images from the Pages file    . � / / ^   F u n c t i o n   t o   e x t r a c t   i m a g e s   f r o m   t h e   P a g e s   f i l e ,  0 1 0 i      2 3 2 I      �� 4���� 00 extractimagesfrompages extractImagesFromPages 4  5�� 5 o      ���� 0 	pagesfile 	pagesFile��  ��   3 k      6 6  7 8 7 I    �� 9��
�� .sysoexecTEXT���     TEXT 9 b      : ; : b      < = < m      > > � ? ?  u n z i p   - o   = n     @ A @ 1    ��
�� 
strq A o    ���� 0 	pagesfile 	pagesFile ; m     B B � C C :   - d   . / m a k e M o v i e / p a g e s _ e x t r a c t��   8  D E D I   �� F��
�� .sysoexecTEXT���     TEXT F m     G G � H H � c p   . / m a k e M o v i e / p a g e s _ e x t r a c t / D a t a / I m a g e s / * . j p g   . / m a k e M o v i e / p a g e s _ i m a g e s /��   E  I�� I I   �� J��
�� .sysoexecTEXT���     TEXT J m     K K � L L @ r m   - r f   . / m a k e M o v i e / p a g e s _ e x t r a c t��  ��   1  M N M l     ��������  ��  ��   N  O P O l     �� Q R��   Q 9 3 Function to process git commits and extract images    R � S S f   F u n c t i o n   t o   p r o c e s s   g i t   c o m m i t s   a n d   e x t r a c t   i m a g e s P  T U T i     V W V I      �� X����  0 processcommits processCommits X  Y�� Y o      ���� 0 	pagesfile 	pagesFile��  ��   W k     9 Z Z  [ \ [ I    �� ]��
�� .sysoexecTEXT���     TEXT ] m      ^ ^ � _ _ & g i t   c h e c k o u t   m a s t e r��   \  ` a ` r     b c b n     d e d 2   ��
�� 
cpar e l    f���� f I   �� g��
�� .sysoexecTEXT���     TEXT g m     h h � i i & g i t   l o g   - - f o r m a t = % H��  ��  ��   c o      ���� 0 
commitlist 
commitList a  j k j X    3 l�� m l k     . n n  o p o I    '�� q��
�� .sysoexecTEXT���     TEXT q b     # r s r m     ! t t � u u  g i t   c h e c k o u t   s o   ! "���� 0 commitid commitID��   p  v�� v I   ( .�� w���� 00 extractimagesfrompages extractImagesFromPages w  x�� x o   ) *���� 0 	pagesfile 	pagesFile��  ��  ��  �� 0 commitid commitID m o    ���� 0 
commitlist 
commitList k  y�� y I  4 9�� z��
�� .sysoexecTEXT���     TEXT z m   4 5 { { � | | & g i t   c h e c k o u t   m a s t e r��  ��   U  } ~ } l     ��������  ��  ��   ~   �  l     �� � ���   � D > Function to create a video from extracted images using FFmpeg    � � � � |   F u n c t i o n   t o   c r e a t e   a   v i d e o   f r o m   e x t r a c t e d   i m a g e s   u s i n g   F F m p e g �  � � � i     � � � I      �� ����� .0 createvideofromimages createVideoFromImages �  ��� � o      ���� 0 
outputpath 
outputPath��  ��   � k      � �  � � � I    	�� ���
�� .sysoexecTEXT���     TEXT � b      � � � m      � � � � � � f f m p e g   - f r a m e r a t e   1   - p a t t e r n _ t y p e   g l o b   - i   ' . / m a k e M o v i e / p a g e s _ i m a g e s / * . j p g '   - c : v   l i b x 2 6 4   - r   3 0   - p i x _ f m t   y u v 4 2 0 p   � n     � � � 1    ��
�� 
strq � o    ���� 0 
outputpath 
outputPath��   �  � � � l  
 
�� � ���   � ' ! Clean up the temporary directory    � � � � B   C l e a n   u p   t h e   t e m p o r a r y   d i r e c t o r y �  ��� � l  
 
�� � ���   � 8 2 do shell script "rm -rf ./makeMovie/pages_images"    � � � � d   d o   s h e l l   s c r i p t   " r m   - r f   . / m a k e M o v i e / p a g e s _ i m a g e s "��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   �   Main script execution    � � � � ,   M a i n   s c r i p t   e x e c u t i o n �  � � � l    ����� � I    �� �����  0 processcommits processCommits �  ��� � o    ���� 0 pagesfilepath pagesFilePath��  ��  ��  ��   �  � � � l    ����� � I    �� ����� .0 createvideofromimages createVideoFromImages �  ��� � o    ���� "0 outputmoviepath outputMoviePath��  ��  ��  ��   �  ��� � l    ����� � o    ���� 0 f  ��  ��  ��       
�� � � � � �  '������   � ������������������ 00 extractimagesfrompages extractImagesFromPages��  0 processcommits processCommits�� .0 createvideofromimages createVideoFromImages
�� .aevtoappnull  �   � ****�� 0 pagesfilepath pagesFilePath�� "0 outputmoviepath outputMoviePath��  ��   � �� 3���� � ����� 00 extractimagesfrompages extractImagesFromPages�� �� ���  �  ���� 0 	pagesfile 	pagesFile��   � ���� 0 	pagesfile 	pagesFile �  >�� B�� G K
�� 
strq
�� .sysoexecTEXT���     TEXT�� ��,%�%j O�j O�j  � �� W���� � �����  0 processcommits processCommits�� �� ���  �  �� 0 	pagesfile 	pagesFile��   � �~�}�|�~ 0 	pagesfile 	pagesFile�} 0 
commitlist 
commitList�| 0 commitid commitID � 
 ^�{ h�z�y�x�w t�v {
�{ .sysoexecTEXT���     TEXT
�z 
cpar
�y 
kocl
�x 
cobj
�w .corecnte****       ****�v 00 extractimagesfrompages extractImagesFromPages�� :�j O�j �-E�O "�[��l kh �%j O*�k+ [OY��O�j  � �u ��t�s � ��r�u .0 createvideofromimages createVideoFromImages�t �q ��q  �  �p�p 0 
outputpath 
outputPath�s   � �o�o 0 
outputpath 
outputPath �  ��n�m
�n 
strq
�m .sysoexecTEXT���     TEXT�r ��,%j OP � �l ��k�j � ��i
�l .aevtoappnull  �   � **** � k      � �  
 � �   � �  " � �  � � �  � � �  ��h�h  �k  �j   �   � 	 �g �f '�e�d�c�b�g 0 pagesfilepath pagesFilePath
�f .sysoexecTEXT���     TEXT�e "0 outputmoviepath outputMoviePath�d  0 processcommits processCommits�c .0 createvideofromimages createVideoFromImages�b 0 f  �i �E�O�j O�E�O*�k+ O*�k+ O���  ��  ascr  ��ޭ