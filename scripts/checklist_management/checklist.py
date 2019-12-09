##############################################################################
# Copyright (c) 2018 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

from datetime import datetime
import calendar
import urllib2
import re
from bs4 import BeautifulSoup
from pprint import pformat


class Checklist:
    """
    Checklist
    """

    def __init__(self):
        self.pids = [
            'aaa',
            'bgpcep',
            'controller',
            'daexim',
            'genius',
            'infrautils',
            'jsonrpc',
            'lispflowmapping',
            'mdsal',
            'netconf',
            'netvirt',
            'neutron',
            'openflowplugin',
            'ovsdb',
            'usc'
        ]
        self.projects = {}

    def log(self, text):
        print(text)

    def getProjects(self):
        return self.projects

    def project_key_value_increment(self, project, key, inc=1):
        self.log("[Checklist.project_key_value_increment] Project: " + project + ", Key: " + key)
        project_id = str(project).lower()
        if project_id not in self.projects:
            self.projects[project_id] = {}
        if key not in self.projects[project_id]:
            self.projects[project_id][key] = inc
        else:
            self.projects[project_id][key] = self.projects[project_id][key] + inc
        return 0

    def process_autorelease(self):
        self.log("[Checklist.process_autorelease]")
        currentDate = datetime.now()
        for year in range(2018, currentDate.year + 1):
            if year == currentDate.year:
                for month in range(0, currentDate.month):
                    self.process_autorelease_month(year, month)
            else:
                for month in range(0, 12):
                    self.process_autorelease_month(year, month)
        return 0

    def process_autorelease_month(self, year, month):
        self.log("[Checklist.process_autorelease_month] Year: " + str(year) + ", Month: " + str(month))
        datename = str(year) + "-" + calendar.month_name[month + 1]
        dateurl = "https://lists.opendaylight.org/pipermail/release/" + datename + "/date.html"
        datehtml = urllib2.urlopen(dateurl)
        datesoup = BeautifulSoup(datehtml, 'html.parser')
        for dateitem in datesoup.findAll('li'):
            datesender = dateitem.find("i")
            if datesender and "Jenkins" in datesender.text:
                dateanchor = dateitem.find("a")
                if dateanchor and "Autorelease fluorine failed to build" in dateanchor.text:
                    self.process_autorelease_failure(datename, dateanchor.get('href'))
        return 0

    def process_autorelease_failure(self, datename, datehref):
        self.log("[Checklist.process_autorelease_failure] Date: " + datename + ", Email: " + datehref)
        emailhtml = urllib2.urlopen("https://lists.opendaylight.org/pipermail/release/" + datename + "/" + datehref)
        for line in emailhtml:
            match = re.search(r'<PRE>Attention (\w+)-devs,', line)
            if match:
                project = match.group(1)
                self.process_autorelease_project(project)
        return 0

    def process_autorelease_project(self, project):
        self.log("[Checklist.process_autorelease_project] Project: " + project)
        self.project_key_value_increment(project, "autorelease")
        return 0

    def process_tsc(self):
        self.log("[Checklist.process_tsc]")
        currentDate = datetime.now()
        for year in range(2018, currentDate.year + 1):
            self.process_tsc_year(year)
        return 0

    def process_tsc_year(self, year):
        self.log("[Checklist.process_tsc_year] Year: " + str(year))
        tscyear = str(year)
        tscurl = "https://meetings.opendaylight.org/opendaylight-meeting/" + tscyear + "/tsc/"
        tschtml = urllib2.urlopen(tscurl)
        tscsoup = BeautifulSoup(tschtml, 'html.parser')
        for tscanchor in tscsoup.findAll('a'):
            tsclink = tscanchor.get("href")
            if (tsclink.endswith(".log.txt")):
                self.process_tsc_meeting(year, tsclink)
        return 0

    def process_tsc_meeting(self, year, meeting):
        self.log("[Checklist.process_tsc_meeting] Year: " + str(year) + ", Meeting: " + meeting)
        meetingprojects = []
        meetinghtml = urllib2.urlopen("https://meetings.opendaylight.org/opendaylight-meeting/" +
                                      str(year) + "/tsc/" + meeting)
        for line in meetinghtml:
            match = re.search(r'#project (.*)', line)
            if match and match.group(1):
                projects = match.group(1).split()
                for project in projects:
                    project_id = str(project).lower()
                    print("project: {}".format(project_id))
                    if project_id in self.pids:
                        if project_id not in meetingprojects:
                            meetingprojects.append(project_id)
                            self.process_tsc_project(project_id)
        return 0

    def process_tsc_project(self, project):
        self.log("[Checklist.process_tsc_project] Project: " + project)
        self.project_key_value_increment(project, "tsc")
        return 0

    def process_clm(self):
        self.log("[Checklist.process_clm]")
        for project in self.pids:
            self.process_clm_project(project)
        return 0

    def process_clm_project(self, project):
        self.log("[Checklist.process_clm_project] Project: " + project)
        clmurl = "https://jenkins.opendaylight.org/releng/view/" + project + "/job/" + project + "-maven-clm-fluorine/"
        clmhtml = urllib2.urlopen(clmurl)
        clmsoup = BeautifulSoup(clmhtml, 'html.parser')
        for clmanchor in clmsoup.findAll("a"):
            clmlink = clmanchor.get("href")
            if clmlink is not None and "sonatype-clm-application-composition-report" in clmlink:
                clmdiv = clmanchor.find("div")
                if clmdiv is not None:
                    clmspan = clmdiv.find("span")
                    if clmspan is not None:
                        clmtext = clmspan.text
                        if clmtext is not None:
                            clmerrors = int(clmtext)
                            self.project_key_value_increment(project, "clm", clmerrors)
        return 0

    def execute(self):
        self.log("[Checklist.execute]")
        self.process_autorelease()
        self.process_tsc()
        self.process_clm()
        print(pformat(sorted(self.projects.items())))
        return 0


checklist = Checklist()
checklist.execute()
