ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.0
docker tag hyperledger/composer-playground:0.15.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� _�Z �=�r�z�Mr����S�T.���X���f���rv�a	$n�%�G��f�\@�ѩ<©��5������o�{�Hػ��Z�������w�f(-d��1,�h��0G��m��� �!�g8&p�Oa��>�����H��G��p�T�\p,� <�M�U��x����E������BfWU���0 xs�����_�U��:l��a.�T۰�Ӛ�25Tk 34��M)��1L�rI [��6�C�٢iH益���n�����Ò\<O����x�e �q�� �@�f�;��x�0��lX�6�(�1(��%�1��m���h�B�Tk�:;� �MC�H�JH1�M
�˕���WB�M3Q(�mX���&�u���3Q�O͹�N��sCG��;��4ꪆ�w��u[S�ê�*�_C�b��vo4�@�]>�ͣ`�"^m]~b���V��⇚F�q(8��x�jxU�Ys�U��p�0�9n�a֐����1�ݣCZ���fG�	�<�At	���ĸ7{�	\ϞsZ��ӊ�>�AҜRm��M�2�f�ϕ���*�-���ߴ�n���;�~q���)�gw݌�A	v�=���>8Ȳ+��0��ԖΛ�C���'�m)�?y��mC�-��;�v�zD�ё�3�=Wj��;=Х�Lj��d��:�p��}
>pw�@u����4t�u!/�̒��?�_�"/
�@��9�_��7e�m��(����k�j.[������?�G�H���En-����!TU�PZM�2SA��|
����&�1���	��w^:���[��5����@�W��B����'�W���a��'k��g]���^�������a����7��Р����r����?������8K����_����S�*-�@����j�g����/��?���@�<Ǝ���*��������|q�r���:i�EZ��D�,`���f�lA�0�	iF�ű�i٠��2���1�.>�0u�tM2�Wm����CoC�=���h�B8��T�+4�Ga�fIy�3J�б��9isNz%\�4UA�E��i���٢�1�gx��%_�.�����&Z�Y��ҡa��[Y���Qs�����T�j��؆�u@ @>����"	x���;�:H�!]Q��&�$��ƃ�!M4�T7��CK�����ˉO���Ajo�f��'�s�?����wxYp�������/`�p��]	��?�	 R�;:u��	m�R5@�L�6�'"`:��ꍑS�b��,��<}�|d�#~w�i�N!б@��3F���D�<���]����KBR�{R�`�q}�6��ެ����	��^�OJ����ra�r�]�Y{�4rP�m�5ۀ�:����bz؁��ר���=�I{�E�}v4b���q��3ǰJ8�1�H��4�]�c��Sݰ�^2�Nu2G��3֣ʃ ؟�A���i����C���c�s�$w`�B�A�=raL��6-Dx��k�n�rq��Rx�=����������l�+�2�Wk�)���@;�^�#����%����P_�N��#��g�8��L���M�3teMV��.�� T�R�z�r�8Q��횗7P�0�Tm/YPaj���G��
S�2����K����h����*`m���a����=ձ`����������p����Jg�с�h�HzD3�e���1aՕ��$𦁅��3�lq�v���-�����Qy��5!����	vEO1����C��",QY9p��ܴ�(f���r��=�?��I͞�;� T8���XF��6������$p����
�Yh6ML�h[��Y�Y����T����r6'Vʳ�C��;O-��f=�ф�һ|�mM���Ƿ\ ���&����}6�V��'�i"��=j$T�����cI�iW�ɂW?/�T
xR��ɂ�Nv��׭x���w͆��3����i�Q��Y�~Eg�L��@��"z�9�B46��	\�#��Xl��_	ܿ�G�j�~�eyL�Nd�P8���].�G� �6�������W�@��д�S\���<7���"k��J���?��Sž'z�T���@ �u�rLxȠw���Υa����������1o������*�R�`��?.&�\�����
���/s)`������7,rk�%0����n�X	7- �4��c���9D�m�׬ CT� �����E�Q�7�D�TL�����c?��e��(��v"L��tl����o�.���X}�Fm@��0��"O�^d�Lo�=W��V<�'R��x�ጙ�2a����ij�5$e#�����g:�U�E!�5y��Ş@ݘ�諈F)F�1�2F�'|�d7p���]���Z�n�4}-r����2�B��1��M�?�pd��[	,����Jv���G�"bÆ��B>:�WA��d�@��?ԛ����= |����x'l�ݻ��ߩ�Q���X������̥��?,ѡ����/
���������-�������'XLAJˍ7tý\�f���� $~#/�"c��Ϛ��Q��0���f�`�� ����<�~�#�<WԵ�u�m�+������\[%�4�/@eh�NN��B�P�ZT���[`Dn��G�_M�r#!�����|z�a�h�����|���Yv�8!�膳1I�	�k�Ƙ��<.o���{��.d�j]%�|�0��������SBo�0^Թ�!���,S�k��H�G7��ޭ�uӰl���9
�����GB�ʈ���xVLy�c�)��/u��5�8Ǵ�8�
��ޘhآ�Wf��2�Fs��1c��b�X*������-	��m央6�K!�&��+HCC�]"%Y!zj�|#3j!�\��y�*�b�j�Sb�an��GuE�n+qQ�0�n� ��EN��vƫ|�8�H��j1I�X^	ז��ɼ�� ��j�1����m p1}m����,(d%��;g�EC�G�C�L?v�n6��0�g�����	V�6�X\�����ًɘvO����wj��!ݫ��	�4��3k�repk�op\hF�>����\�������/�h�#�D���������쿫1Sݢ�6�6>�Lh���O�	�3�~����ϳ�����`�\tr���������a�w�~��>�Q�N+� ]it���_�˒�^ e�-�.tfQe�Δ� �
g"���?�9M^�f�>�!4�r߮�f��[�W����E���n~�;���s_����J<�i�sT2o"�t1wFֆ��Y/6P+Vz�����:�U���@����#������Ý�����Sо\T�9��p��0!�E"��Z�[0��-sμ������������_�?q���3
W9E��v]�^��z�.*��x�^���H���xXT����|5��ۑ��|���[f�����/��J��F<X�`6�c��o���d���[�i�N{�7����`����뛍?3N�߿���e~G���?o��w����=n��������W�������o�	~�""��>/a���y;�?�Ȼp��O%�;�q��_8�����ߕ�'��Ь�:���;�c�TX������X�!��Z�iCMc�+$ħ���u�?��}��Ź7�d<������7�T��eYw�BR����Иx�@B�d�xϲ�lR*�4����f���dRR���MH�lQ�;��q�y�Jd�ƛ�j�-��K6N���Y�ꂓ1nO��0������h��ǹK�J*&�cL��l�Ռ֮�_;�D�L_H7O)��q��ȼӕv�9��Sa�2S�޸FY���gW�s��٬�IXg��EU�.�RtqreY�7���������ϕ�^�"+��YNH�M�i����D5W�z��i�P�Ƚ�Ǖ+���GZ�L��Bڂ'g]�霖�\���2��W�������'��&Q���G1�^�pR��ID�}��JeҶ�����n��8�=��e��RN�K9�Lz�{��e�D��޿L�L�T��X��z�r��)�'���Ğ~�:9�i�J��K�iX+�j$;��uz��|)��r��b�L���Fo��\N�$�涖�ɉP�@�x���r������Tߖ�I�%-ҪZ�Wh��R6�6ϠKd�w�Y<h���:m�������hN^G��,wr�1l���5��\IfI��/D��I��Z>E�6��GN⡦~�<��FPI?����d-��6J����ο�׌�!w�����1��Ns��;���O��X�����w:��r>5e�����P0��7T��@{�o��g��'ǻw��� ��.�<?c0��Mð��-����'��������n�V4�����'����������}���>fr��>��ygt"�� ��
��e{�}C��V5��9;�����3'����)�\���4�ȕ����MZ�J���UZWi��=�:�I�x^E�ǌxܪ��H?��P�r�'d�F�y�W�)
H��JU��Aj�̡6J�F.���|7��{�ˁe�� �Ա`�����#q��Ws�$fY5�YVKb�U��eu$fY�YVCb�U��e�#fY��YV;b�U��i�3S5��P��O���E���*��N�s7}���O�������*���U٤_�K�zr�tϓ�Ra(㥤��*4$�z��NU`9�:wy�pB�^7:�~���t�%#�)��q���x�0$������l�n��Q�?���%���r����_����s��o>a��nR���-�c��������?���������4.>����NH��$�ED�E-�<!Q�G�7��g��/��"s�~��a��������f�bA �P]�U1k�IT��*hC6�UY/j�F�>xr�,��!?-~��	=��� y�#� Hm��;�_K��nB�-u�BG���HzT�f�h*�j4d#����↲2�m� �3,���xo���D��ֳ�D6?�p�P��?��m�c3w2<����ѯ���Ga7�S��_B:�j��Q�Ļ�6^"�)D"��u�7ӣ�ԎI�U���v3��zP��i��v�w��w5�<:���(�h��O*$��/�T��i����I�}���=�B�y������41�#i��C�v����bz��7��^b��'�;��q~�N'Z��q�q�t��IV=i�	��q��=p�� \V �\q�PU���N����o�?�tR����ﯪ��o��H�AC=��pz�)0���S(�'�Ɩ����ę9vi�A�`|�ۂ�[�����60hB�g�+��� ����*��!��wt�M�������w������R�'�W�b��X��v�� �B5�9 �.ɹd!��OȩjM��Uc���H;$m�G�o�0M��b,�}�rə�+��y�4ʝ���������2_�*�y �<;�$��%髻.>ޝ|������� b����%��$�����'W��x��E.1Ls?����y_�wKŐ�ə�����ɮcΠ�[�����Z�5!� ���j?t_5�|6V����~�����r�.A�ɞ�z�&�U�c�ѣ����و��r�!B
*6��3�(Tz�̂\e���`��M{���D���4m�j��;,�eu�\��� {�^G����L����2wD9҆�#�a;�n��܍�~H&��5�@�V×9?y�
h��<�9<2�;vjY8��]��p mP(ҭ$���;�<��(
�SDxx��Z���5@�L�o�CS�PC[�p�+�z�O%�����y��<��}2^�<��?�����S��ߟ�e��h�s�����g��o���7��s�w(�S��E,�_�{�͗￶�#|V�ut��bTW>�v"���@"��Si�J�≴�ĩ��J�b2��&�,�T����dd���_���y��_���G�8��g>��~�'��Y�O�{�~��n,�[��?�M��>EaE����w��u�"�oE~�w�ߺ������Z�_�E>���{�O{�͑�}����u����m�:W���L�u`�lQMZg-��#V��ój�^�3v�������[�Dh�+�=��@���3�{"k���Q����؝�Q�NlQY1�x�Y�g��x�0m�Ճ4B,��܊)����1�%�!:��5�w&\���tG٥<2b������;������@U&=�2C'��G�����-ʣ�D�M9r�5��Y[l8NA�y8�_T�:���7X�&�u�JuX.3Z�ꨴdGJ�|-G-����3����]-nbX�j3�j��n�21X��y�:w�j��J������|��P3�S/FY��V�Lo�� ~D�S �<��8��3Kn�à��3�{��/hu� l�<m�Z����Ĝ���-%���H���,w���`r��v��d���rz5Zg6��&��"�1����JM�I"g)=��:*ϴ�P81z�d
��͖�`
�3��)�����#a�J<Qc��b�|����/�J�t*���T�~�x�Yd��k�3�*�������9�??��F�=[Q�J�3���ڡ"jgM���+�/�z�(;�V=�=�S=�+ ���ݘ\���!|�s2�j��8�(�K�����]���t�-�zgKc��l�HY�-Z<)1�9��B*�o�D��J�v2�hs☠����W?���E���&�?�1�D�_��N��e$�U�����V���ϝK�O�)��*E��|6�R�DRK:U�mqN~�ikY}��ۥ��検f�Q)i�/T���T�۪N{5B��9�����<��WpYp`7�}?�{/Gމ�E^�_�{������g�b��7/��Y���𷉷r�)��䣛bMC�-#F���Jd�o��w�^���_� ]�b��~G"{�-�F^��4�b���'E��N�_�N�6�"?���?���?�������ޣ�?�V��WP�)`��;3�J������§')�߻����u~�c������|�s�`�x'�XK.�6V���/���X�a�E�����'�{[��l˗�U$|�
�L���H������Ȳ�ǯ�u�Y��+*_L�R�T逛���Y�Ȧj���HɎ�Ju�N�@�j]�h�K1�����I���ce����(_�taR:6��C�HLՕ2��Z_"p8V���;�1��=�J�Ũ�ô�pZ]gs,���Hg���3�~� w|�N۠`�C	�Xr�|���3\1GĆ��*E�cyFg�u9��dJ�F�c*&�'���
--���uk4l9=!�(W�I̪s}*:`�� a������J�hO�ft�҃�U���o\�49d(ˁ�\����Y��g�UK������Kd_������9�dnT�����M�p�βr�/+�pY1L�&�i\����e�݉������Ϙ��<h��rۘ�7S�Dx
�*�Wg�m��|͞k���kt�`I��q����M�R��z�5Q۫��Kl���]�1�f)8�:�5f��sg�h�¤���JE�*\eD�qe�5�s"�8G.�����#���-Ĥ��k	A�s��������Ӊ=���ֹp��
%�nB���0`D0;�djj�{������R&|����6��8�|q�hH�a4NJd
�B�+��f���ұ�fv@K1*FK�z�̔V���d�ŵ<Q��"Y��X���񉞞�T�-+/X%�̽XEb:�S$��o?�m�`Ă��	q�%_�k;�Je�t�W&d��
��y�W(��8^o��r�+e4k<QK�����p��,�ߦ3�n�)h4�:�&0�l�S�&Y�LURF�e
qc���u"�L�F��B!|��C��[�t?`���T�a���V�G�����J/zܔ��X��$o�PXzP֛���d]^̨�r�f�sr�]Ԙ��HtR����a�z+
X����f`$;"�Z��U��G������^;۬rF�����4��KD�	m��!����7¦[P��ƛ���M�
l�_"�y�hC����E������Y������%-'j���kī�i�A�}�gX`�M}�Fފ��G����S�ݧO� �7�7pɽ(/��ȫ�+��f�����h����!�En��mB��J����"��Xc̈́�#d�������y���+��[��)F�����kAv�x�FQ��e�V$�O���>���񍎗�E~"X�#^r�}�|���ȟ�^���?����R���$�/��^�s7��H���\?IzWO{��������O7��S;a�*��(�
9���><L�<�0�9S0Rm|]��"r�]S��i�j�w��Y��96aN�dl��f�w�I�ow���o}���{ù^�F��p'�eI�Ǐ׫=���6�f����A^ScP����tU��F�7��pjBoo��л"��t�َ�ƥ�'��P�9B���]��<]�A�S��A����Pr��"��5����wA�[h�����}cZ�����>^8�w�$����Pȱ
u�r��������/yf�2 ;A>_{�a�*�0y¹���`K�Gz�n.jax <��A�5z��!��·��}�a�޹j���������A��}Ը4�C�E��PC.~`M����� �ON����X4��_'�x]�+XA%� sA���̠�L[���,�N�#�A�qx/z7��� �kS}��'�8$&�(�"�7���j����D������k��W7F=�us��L�����c[���Q@�������w������>@25-����/��-��=�����|S��4Zs�y��a�&�7������Đb	$4buao@s=�q/b��N�D���N���8|N���1�ku��g�"���8l�8�����n1s��m"KZ�H�T5�g���m�ZJ� T��(�d-.�n�~�'�����/����C=��ƀ%]G�}�.��}z���?�۩W�[���L�ל�l��7�b��2��^0B^�X��d�N�a;#
H��p�k!�$mmBG)���SӰ���G��8@8��9� �5pcC��)�e�>�#��G�Ѯ
 ؉:�� ��P�p������3��Q��҆Hvq�_�WF�P��q���"�zu�vKY7qݰGk�Uk�*�fH�����/t�e�y���so��������6T���kA��{5bOtH��iB�6�l4�-��G��5B�My9B|r����C�`�Q @�u��������C��2�B�*U�?�Y��!r86�M�įkKLSt�Q����,����y�i�7�D��f!I�
MśP�:҉�<8�n���8x6�X�s:��Ʀ��܅���
@Hq�u�!����`��z�Q�?ϼ�w1�ٵu\s�?���[�?��ԗ�_�ㅌ>$?�?$DzϵJv�\re�>���pg�y�yeMx����r�9�EFzU�^t'8�&wl�c���UbGc���*�6��B���g������#��l� �V@?�L�4 r2��U����d?���zj�R�}
 Z���YZ��r?��DFt
�(�aH���[n�-���r�V� ��p�=��K>�)��G7F�M{�c@��0����@RY ��@��X"K+@�h5ы�,  �Jd�t,�ʨq +(��CLf�j"�R T����;ğ�|������n�!t=z���==�io�!��S����vQ1̸k^������p�W�fl[mp|Ru����|Z���1_~���L�<�Д�
�q��|��U����oSh��T�r��R�5Yw���rɁ�+:�c�b�&p�C�c��F�/4�	���U����TA�3QsbG5��E�i/���`&cZ�8V�L�_P���єѝ7� l��/�����lϸl�	��C����nc־{�d7�_��r9ɣB7��\��#"/��i��[���犌P�U�uN�'8�m6���|��U���x6���h�����4:��=���O\U~
)��գp^��.�&^Z�nW����jS�U+y�pZ�v�q$��=���4|hw���q$/f��.�#/�jp�,�A�,۔P�{��1�2M�qΜ�{E�\��+r��'�*�ȇ�l&�\4��%У(塇=|f�q�z	S����M⠓�1u@D��4�������Fw�n���[֋�1�-V�+]Q'�X�N��;�ڂwI a�S�nm��Z�� �%�ֈ#�[�qı��FV�8��T�Tt�Z�lS�/v���‡I����e�ʚ�ƶ�~��NU�yx�UW �B�z��	!f�@�_��wҁn;N|t:ޫR)�؁�=�Mq4'P,���`�#����F��7��7��$Mp�(�������s�s�������������I��F�����,�߳6� (���ϳ��H����=�s��_��T����ߗ�~>-P��?������ߑ h��h~�M����{�����q$��(p�"9Ĉ�rK�Q0c�0��PD*�y�gL�p�dS,���>�����C���Խ���_H����~M��.f�I����v5�[{�6�����唑ԏ]�7���yt�����q�n������Z��������+�����9�邚��>�3~9=�K�<���␌������R�O?ݨ�]}��������������u�x����y���'��0��G��&���@���X���� ��������  ��@���Ԯ�%�� �����)�>��	0���Q�[#d�����r���{���Q /���/t��*����O�����I��� ��U����_���S�B�Q�?��	0���e���s�?,����� �G���C+ �?G��2�������-����j��;�a-_��V�e�a���������}���F?�����=FX-�ݳ���O�}��E�|�̪��}s�/c��ҡ)~�h�r�Ռ�l_�u����z�{\^��]fRenύ��[e�8�ݶ3�jˀ����}r�}q���!�Fn�>��2�I���g��W{!ӓ��ǁ���k�ks�|��'ǘl/��f9������}��â�.re�뉕gI\qe-��C-ٱj�ڴ4;�D5��U8�x�4v�y_nnD���A��/���:��,q����-i�����e�@�=�B
�@�������ʀ��Kj`�?�b`�7���?���?U�?�4�?�@�ei��U��ϭ�������_���G����7A����!������j����_������i.�x�4�U����o\�od�����	�o<�X�߇��k��^�5�	5}�g#X��Y_]Y�>ȝ}m��sq@v�6ox;�Xf�`;�b$���&n��1?c�S����mn��m[z����cْ���^�	P-Y.��~��Nal忔�:�[�����c.�lJ�J�0I��%Oobmo��5��(v�i�MҕS�;83|q�HuVQF���TOՌ�Xg�!����#k�������,��@�Q��P ���/Y�=��W ��?��Á��������8�4(!�qT�<q"�"Gr��d�b ���Wv�y!�� $��9Fb2&aG������?�J����x��*�^�Q�y"�f��PJ��Z�j̩h-�d�M����#���9���)����I�9���#���t���ɹ���v��0j�-�=մa�G�.�6
v��K��q�?~�������?�C�����o�������:`����S0������5��������!���2�;ڎ>8�z��'B�G�?������n��97ζǗ�O�0|W�I��
�}������M�)�sbV�i��g�%�	�O2�>m��ȭ]V�Қkw�.�"{cG�I����������!�[0��C����;�������_��`��`��?�������X�?A�����P�5��W���_��{	�7Uُ���9k���������������Ʀ�W�5�� �Ӄ?���V�>�p��as�
�C�Jܖ ��@vN�-��r��ɷ�Yn7��\z�ѫ5��.�Nc�p]��Tː�%v�̉�G5���~��s!yW����o֋�"��n�|y
7�����v 8ÆRX�58(��P�ⓐoXХ}�UO�^l7O#ED���X)�Db��=�2n7�١�Yj�<��8sK������&F���i�P&��p�i �-�Q}d���k����.C�6��-%M�3��l�-?��G�.[t;r�,b�����2����[�Ŏ�5���T}|Y��~&�=h�����������>tx���Z��|��A����8�?M>����? �������G��)� ���������������D�Q��Ɋ��E�lH����<�J�@��3~ݶA�MG��BL���`����Q�/�$����^78.Kc7��7�	.��HVϚ]�s{?bK޶ح��_�ݾLv�޻�n�.���hz�q�O��Ol֌�ݥ��0钴>w���eē�])�>��ǖ5�Rg|P%�k]�Y7���������� ����7����%����ߓ�gy��� ����������S�x�����U�?M���`���|��P����G��9�(������_���cw3�k���4/ۉ�n��ʹ���J��5����i{N�L���1�gz�o�l�{��b���?��Ǖj�#^��nE�8Tsyv�h�9	�$�����ڜ�m���,�#a�Φ�)�?rӔ�O�v�&ڮ`dV����_�Ia.�c�l���r�g���ٶ�������GA1�8�;��\�wk7��=�j��R�͵X�?�we'��U�Q��txBՓ}0�Ƭ�7���W4����xX����#q9�߮��%�6���׍��KLFV���Ee%��þ�u[62���j��V4����
��?��Á�i��׊����7��?�����	��������������_�� �% �������u@��O_B `�?���(��Q ������������o�
|���n?���	x�������	p��$���P������?������B������r�����G��!*�?����=���H���9j�������	������_���S�B�Qw�_��@�L�T��?��Â�����D���a,���?����	����������"����ϭ�����W���!P������H ��� ���Pm��@���#`���4���� ����X���{���ߑ +�����!����� ���������������?
�
`����%˷���
 ����8�?C�����D���)�*2�`F��Ȑ�L��Y�b(�43ǋ�O�K�>%
�P��K>�r����z���������"|��������O_��f�q���*M��o��IH�(:�ܦu)]<�u��R��n�W�Ӫ��a�7�}��e[����f�����l��P+G�Z]mkA��h9�8}��5V17��f����f��]:��P�k�㥣�d��k��ԯ��ݓ���8����Y*���T}+�?������ʀ�?��?�a`�/�'��_u���_/d,�\˻��Qۘ;"�uf��Z���߼���;�y�o�/�� ^���]�e�����07�tuԜ�dN�q�I|��c_N�Jp�7��twn�����z]����dL��7��\�l���
<������E����#<�����8���Wu��/����/�����j�?�� ���a�����xM�u�����?��1�X=�w�d���$N���F���߳��I;M��I��cH����u���n�k�i)�y�mMwAB�(���`?N�V�}�<Q�N2��~ƎͰ��~!�e.�gLfۗ���;�d�݁ogVs[��n�|y�oOG�����aC),��^8(��P��;y![ī�]ڗ[�$��v�4R�@���Ў�r��Hؓ.�v3�����@([��-���f�/4L&������ӈX�;go��R��Yz��*F1�F��[����*�E�Lo�]k����Y�g�'�����?���C����o���$ˑ����_$����~�������b��� ���b���7|�����Z�����q�g���Q ��I����� ���O�������C�>�ǒ,�?x-�gTU�._�?,��vv�I*-JR:��g��
\h���������J_,��猛v�Q/���޽V�xJ������#����BO��|���ԥo)�K�K]�2�7��[ے�@(I�%�j(_������:��a��(4�]-�WnO'z���u�7��NW3y6�œ�FB�em����,�S��)y����p�̪͛�����aK��d w�K��S*�)��O_ʹ��J2�o_˚�{I�O�<�>��������IU���`��g�)?��٦p����r��"�ϡv �>k��e��%k�.�
=冷�P	���|��h4���<�H�|Z��bj��#Q�a�W
�<%��:(,�?�NIzz]cW���c��j������^����������h��pd�S�3�bi_�1!�_f�P�]o{��g�P`i�3B��\HƁD�1RLvp�����������W��k|2�[^~4zi�
HB���t��������YD�=%���/W�U+�{��M�@��[�џ�[����� ��8�?J`����� ��2�������������딷���5�g��;�R���/�.�'|4��� m�/,_��{���l��r�?�������R�rK����/y���񶼟ä��r��j��#��횶�ō�CH|���HZSvwM��UK�d�K�y���:��l�,��ʙ8��u���Ʈ=�������^�~ă������ۻ�&7�,��_�q;:zB��"��=� �}�&&܀ش $$U�H��%��.(��2 �z޹��{�ͱ�i�#C*��"Ä��nY�<�3q�ZV��Nl�����S���N%Z��f�cC}ʐ�i'QL�R�^�Y�"i�{m�����������֋�Ӝ��:�jrk=@���X�_���<�?�V������J�5R��r�JF� �?��?Q���J)�RV�X�F�u���S�B�T�/WJ����������M��G*���b��x��DJ��C�Pf��Q<���ǪQG�ށ浚����eْ��{e���?��O~����!)��Ky��ڻ��4����$��0�c.���5���WvH���60����8��]��	�*�����?�����,�6�֮���N`��������F-N��?4?��Q<��˼��Mۺ�( �8rZ
�Vuvl/�c��:��n�L>/�~X��B�2r�|���e�
y��r�Ξ�%�ĕ:Y�z��,���>�z�\��=���T��f��I�p�ϫ=���&Z\M����''qU%����y���+8E+۞�e���/W��҃ٶ�n	�/�m��y�G�<�#�b٨q�Yr|/�]֜l-�5{]R6��ao��]��Xۆ��-�Dn���&/�[WV]�x���l�-e�Ц�.��z�6YGO��}�J�m���%�����Y�:$�RM2V|͖�54�� b�:�cĐ�Qn�~����4���[�C�O*H�����
���[���a���&�C"h�����F�'�ߩ �?!��?!���A������� r	���[���a�?;���`�3�"������O���o���o����g���ٿ�>K���������� �O������?SB:���-BN ���=�������T��'��Y�; ��?{�'����)%d����=����3����/8��	��/DFH�����!���H�� ���p�ȅ��n��B�G*�R�AQH������_.��t�� �)!�!�!�������C: �� �����i�?����߷�����f�	��/DF�E�����0��
����������� �?� K��&��g���[��������
������r�C�f��������E.�F��OF�R���c���v�����_���_��0�CJ��k4��:����h�`�jT��ea�ʔ�3e�HZ3���k(R�*S�1�z��G��G��D_�����^��ݾ<�âBC�]��ƚ��Zw�J�Y��/����H�q)I�@�g��i�ӧ^	���!?C|�M+T�kLE�6���f��:-���p����6A�Q�(r�Q9@�r��x��y}Q'�=J��:7XSjk�뚢Ҹ�Is�4u��ǚe�8ʍΰ�ª^���]�T�<g�C����!��?\èo����������%���1��
��<�?���G��b�i'����r1�bT�t�Ms=���.�;s6��a��,ڝ�j�j��Ƕ�f�O�
GwHL�x�.���vǴk%�6�Ѣ�p"�<��j�]�'�� V�o�M>PN�>��k������!��_S5�W��!�"��2�A��A�����˨�4`�ȅ���k�G��K_��{������6C_��U�FqlK7`�_N�����>b����{��Lr��;ې��m,&�\��Oz�Q��<<����(�x�Q�i�)s�aR�Ѥ�e�X ���UbI�
�M��)}b�Z+����]�4~�K��m[,yVg�t��V��[eOZn0η��9S��V}*S�f�Ւ�^e����\D G����[B����+5�Kɇ��|r��D�X�=����wp�'ibkoT��T|K?l6�5��0+���b�X��g��bz��U�hgL���@�QG�0�S;(l���k��ȃ��)��
?��� �=r�4��������j��H���F���R���/=��M�����Y�?�]������@����e}�������?~���RA���b��=��?s�'o�@�o*���d�H������!�#��#�?����"�����/d��`�L��}�\�?���r��0�c&�E�O_��P��
�Z�qJ�?���rX�w���u�ɱ-0�)�0���e�n��������z��H
+���]=�~$?���ڏ��yE��ō.���K��{y]�o�d��Z�;�b���<]/V��..{H�}cQ������Y�ho���nX��U�O��Üd��19M7bݴe�>N�~������"7�~U8ml�EM�R�&T$w����X��ך��lub���_֞��Uw*���m6c�S�\M;<�51JE{�f5�4�ﵥv����Z��[�Z/��Ns"/�$�ɭ� ��2c��� ���3C����$�Y_�{�����r��0�����O� U�"����E��* �/���/���6�'a�'#d��>N����K@���/�Oa��!G�c� ���E�����k��������o'n�f���v���6������>�E�y�h�M�m��K���  ���PP�[��?�d�i(��(�UECiƭ��}�3h�ʬMl�*S�����-�գ:�V�4�PB�u��@[Vd�9��\�$E � I� ����Q���Ic]�*���p��W����%ک#�-3��%����c���T6mi0��B�)v��ݥ�ZQ@�*MUc��ڑj9�|��ȅ��o���_� s��a��}����y��~��������d�d4���hJ������4��aV�����`�Ai���z���~����WF��������~���Cf�l�)����cN�X�NC����qL��N�X��,�/��GwJ���Y�<_��l{'�ߙ���V�Y�YR��~��ӧ�M��Q��I8-&5tM��Y:��]l��0��k����?�C��2	T��Α��������̐9�?O��Y_��D����#�?o�[O���v�:�.0���He���Π��6ћ��ao{��������<�J6�;�\�|�7
���@SS�4f�1DǶsڕ��W�Î�j���}��v︉ց1=8$��k����*��bHh��@������"�_P����꿠�꿠��_��?��A�E�@�e���I��L���kZ�GO�}�@�"����-�\�t����s����W�\&xYP\��NYt�U�^���X7��=8�w���,QW�x,�*�
-i�y�	�4=��CkS�ԋ��q��fC�Z���b{���K�[�>�yH��8��j�g��=��܈f���(�$�7���^/��*�q���5G�\��p��˂̫��n)�,MI�*�EH���>��G�����Yͧ��fS�
�\��n�Q/"�rr��R�~���=I㙱tr,gI׉{\��c�n$��}���<�W�V	���'{�1&�ڨ���b4#�xiV��r����r��Uw�z�^�f��12���?A�4���͹�;����+�^xxn��=~��?�M̨��Â�r}�ϋ��.;��{۝T��v�!�݃细�����9K)���
�.�v!�v�U�����`��?�Ɋ?�#o)���/��}=>����˝j��[�|������%�|A2^��'oI(>�y�o������4�Y�A$���O�/T�TUA�VvXp��a�AX�}���Y�|�	�z��1�Y�H���}������_#;���u���w��9�&����=K��BK/h;����-l?����HU�{��mQH��W<}����8vP{?�����������o
�{���x���W~�w���o;r����߅E�"	������O�y<n���"��f���GJ|]�/Ԏ���������T����of;���5Η>(DVL|��ql�,�cz�?܃� ��O	y0d���C�%tF�w�^+~�K�n���� �f�������w$X��ŵ�ѝ	�|�)�|��1�Z��u{t}�?-�l_�λxp7���`��Ĝ\nT5��x��K�p�䓃����C�����x��,�����]A�o�|�-��S#wuI�.HH�<w�翔l��Uf�����?7��s���>>�e            ����Xނ� � 