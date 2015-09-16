$( document ).ready(function() {

  $(function() {
    $( "#slider" ).slider();
  });

  function differentVersions(list) {
    var result = [];
    $.each(list, function(i, e) {
      if ($.inArray(e, result) == -1) result.push(e);
    });
    if(result.length>1){
      return 1;
    }
    else {
      return 0;
    }
  }

  var modulesVersionInfo = {}

  $.each(modulesMappedToProjects, function(module, moduleDependencyInfo) {

      var projectVersion = {}
      $.each(moduleDependencyInfo, function(projectName, versionInfo) {
          var Versions = []
          var Paths = []
          for (var i = versionInfo.length - 1; i >= 0; i--) {
            Versions.push(versionInfo[i][0]);
            Paths.push(versionInfo[i][1]);
          };
          var differentFlag = differentVersions( Versions );
          if( differentFlag===1 ){
            projectVersion[projectName] = {};
            projectVersion[projectName]['versions'] = Versions;
            projectVersion[projectName]['paths'] = Paths;
          }
      });
      if(Object.keys(projectVersion).length>0){
        modulesVersionInfo[module] = projectVersion;
      }

  });

  var tableString = "";

  var num = 1;

  function groupInfo(versionInfo){
    var groupingInfo = {}
    for (var i = versionInfo['versions'].length - 1; i >= 0; i--) {
      if(groupingInfo[versionInfo['versions'][i]] !== undefined){
        groupingInfo[versionInfo['versions'][i]].push(versionInfo['paths'][i]);
      } else{
        groupingInfo[versionInfo['versions'][i]] = []
        groupingInfo[versionInfo['versions'][i]].push(versionInfo['paths'][i]);
      }
    };
    return groupingInfo;
  }

  $.each(modulesVersionInfo, function(module, moduleDependencyInfo) {

      var rowsToSpan = 0;

      $.each(moduleDependencyInfo, function(projectName, versionInfo) {
          rowsToSpan += versionInfo['versions'].length;
      });

      tableString = "<tr>";
      tableString += "<td rowspan=\"" + rowsToSpan + "\">" + num + "</td>";
      tableString += "<td rowspan=\"" + rowsToSpan + "\">" + module + "</td>";
      num++;

      var row_module = 1;
      var row_project = 0;
      $.each(moduleDependencyInfo, function(projectName, versionInfo) {

          if (row_module===1) {
            AllProjects = "<td rowspan=\""+ versionInfo['versions'].length +"\">" + projectName + "</td>";
          } else{
            AllProjects = "<tr><td rowspan=\""+ versionInfo['versions'].length +"\">" + projectName + "</td>";          
            row_project = 1;
          }
          tableString += AllProjects;

          groupingInfo = groupInfo(versionInfo);


          var row_version = 0;
          for (var key in groupingInfo) {
            var rowsToSpan = groupingInfo[key].length;
            //detailed version info
              if(row_module===1 || row_project===1){
                AllVersions = "<td rowspan=\"" + rowsToSpan + "\">" + key + "</td>";
              } else {
                AllVersions = "<tr>";
                AllVersions += "<td rowspan=\"" + rowsToSpan + "\">" + key + "</td>";
                row_version = 1;
              }

              for (var i = groupingInfo[key].length - 1; i >= 0; i--) {
                if(row_project===1 || row_module===1 || row_version===1){
                  AllVersions += "<td>" + groupingInfo[key][i] + "</td>";
                  if(row_version===1){
                    AllVersions += "</tr>";
                    row_version = 0;
                  }
                  if(row_module===1){
                    AllVersions += "</tr>";
                    row_module = 0;
                  }
                  if(row_project===1){
                    AllVersions += "</tr>";
                    row_project = 0;
                  }
                } else {
                  AllVersions += "<tr>";
                  AllVersions += "<td>" + groupingInfo[key][i] + "</td>";
                  AllVersions += "</tr>";
                }
              };

              tableString += AllVersions;
          };
      });

      tableString += "<tr></tr>";
      $('#version_skew_table > tbody:last-child').append(tableString);

  });

});
