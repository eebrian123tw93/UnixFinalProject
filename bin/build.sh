rm -rf build
mkdir -p build/hydrogen-1.0
cp *.sh build/hydrogen-1.0
cd build/hydrogen-1.0
dh_make --indep --createorig
echo "hydrogen-backup.sh usr/bin" >> install
echo "hydrogen.sh usr/bin" >> install
echo "hydrogen-restore.sh usr/bin" >> install
mv install debian/
debuild -us -uc
