#!/usr/bin/env bash
PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"

OVERALL_EXIT_CODE=0

CDLAB_BASE_DOMAIN=$(< ~/.heiseacademy/CDLAB_BASE_DOMAIN)

IFS=`echo -e "\012\015"`
for L in $(< $PWD/services.txt);do
    TSCHEMA=$(echo $L | awk -F '://' '{print $1;}')
    THOSTNAME=$(echo $L | awk -F '://' '{print $2;}' | awk -F ':' '{print $1;}' | sed "s;__CDLAB_BASE_DOMAIN__;$CDLAB_BASE_DOMAIN;g")
    TPORT=$(echo $L | awk -F '://' '{print $2;}' | awk -F ':' '{print $2;}' | awk -F '/' '{print $1;}')
    TPATH=$(echo $L | awk -F '://' '{print $2;}' | awk -F ':' '{print $2;}' | sed -e "s;^[0-9]*\(.*\);\1;g" | sed -e "s;^/;;")

    # echo "TSCHEMA:   $TSCHEMA"
    # echo "THOSTNAME: $THOSTNAME"
    # echo "TPORT: $TPORT"
    # echo "TPATH: $TPATH"

    echo "----------------------------"
    case $TSCHEMA in
    https|http)
      echo  "Testing $TSCHEMA://$THOSTNAME/$TPATH -> "
      echo curl -k -sS $TSCHEMA://$THOSTNAME:$TPORT/$TPATH

      HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" $TSCHEMA://$THOSTNAME:$TPORT/$TPATH)
      echo $HTTP_CODE
      case $HTTP_CODE in
        200|301|400|401|404)
          if [ $TSCHEMA = "https" ];then
            curl -sS $TSCHEMA://$THOSTNAME:$TPORT/$TPATH > /dev/null 2>&1
            if [ $? -ne 0 ];then
              OVERALL_EXIT_CODE=1
              echo "Certificate Check for $TSCHEMA://$THOSTNAME/$TPATH FAILED!"
            fi
          fi
        ;;
        *)
          echo "HTTP_CODE: $HTTP_CODE"
          OVERALL_EXIT_CODE=1
          ;;
      esac
      echo
      ;;
    ssh)
      echo  "Testing $THOSTNAME on port $TPORT -> "
      echo "nc -w3 -zv $THOSTNAME $TPORT"
      nc -w3 -zv $THOSTNAME $TPORT
      EXIT_CODE=$?
      [ $EXIT_CODE -ne 0 ] && OVERALL_EXIT_CODE=1
      ;;
    *)
      echo "Unknown TSCHEMA $TSCHEMA!"
      exit 1
    esac
done
echo "==========================="
echo "OVERALL EXIT CODE: $OVERALL_EXIT_CODE"
if [ $OVERALL_EXIT_CODE -eq 1 ];then
  echo "Tests FAILED!"
fi

exit $OVERALL_EXIT_CODE
