FROM solr:8.11.4

USER root
COPY games_solr.json /opt/solr/games_solr.json
COPY entrypoint.sh /opt/solr/entrypoint.sh
RUN chmod +x /opt/solr/entrypoint.sh

USER solr
ENTRYPOINT ["/opt/solr/entrypoint.sh"]
