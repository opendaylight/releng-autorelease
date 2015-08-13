"""This python script is used for parsing the various project directories
for pom.xml files and creating a database of module dependencies.
Location of the directory is taken as input.

@Author : Abhishek Mittal aka Darkdragon
@Email  : abhishekmittaliiit@gmail.com
"""

import sys
import os
import json
import re
import xml.etree.ElementTree as ET
from StringIO import StringIO

"""Calls the system function to generate effective-pom files"""

def systemCallMvnEffectivePom( directoryLocation ):

	os.system( '/opt/jenkins/tools/hudson.tasks.Maven_MavenInstallation/Maven_3.3.3/bin/mvn -gs $GSFILE -f ' + directoryLocation + ' help:effective-pom -Doutput=epom.xml' )
	return

"""Removes the namespaces from pom file"""

def removeNameSpace(it):
	for _, el in it:
	    if '}' in el.tag:
	        el.tag = el.tag.split('}', 1)[1]  # strip all namespaces
	return it	

"""Removes #set tags (if any) from pom file"""

def removeSetHash(content):

	index = 0
	while content[index] != '<':
		index = index + 1

	return content[index:]

"""Init XML file for parsing, returns the head tag of the XML file"""

def initXML(dirName, filename):

	xml=''
	with open (dirName+'/'+filename, "r") as xmlFile:
	    xml=xmlFile.read().replace('\n', '')
	xml = removeSetHash(xml)
	it = ET.iterparse(StringIO(xml))
	it=removeNameSpace(it)
	return it.root

"""Returns the dictionary {groupId : ,artifactId : ,version :}"""

def getUniqueId(dirName, filename):

	root = initXML(dirName, filename)

	groupId = ''
	artifactId = ''
	version = ''

	#makes project as the root tag
	if root.tag == "project":
		pass
	else:
		root = root.find('project')

	if root is not None:
		pass
	else :
		return {}

	for child in root:
		if child.tag == 'groupId':
			groupId = child.text
		if child.tag == 'artifactId':
			artifactId = child.text
		if child.tag == 'version':
			version = child.text

	temp = {}
	temp['groupId']=groupId
	temp['artifactId']=artifactId
	temp['version']=version

	return temp



"""Returns the names of the major modules in the pom file found under the first <modules> tag of pom file """

def getModuleNames(dirName, filename):

	root = initXML(dirName, filename)

	modules=[]

	#makes modules as the root tag
	if root.tag == "modules":
		pass
	else:
		root = root.find('modules')

	if root is not None:
		pass
	else :
		return modules

	for child in root:
	    if child.tag == "module":
	    	modules.append(child.text)

	return modules

"""Returns the names of the major modules dependency in the pom file under the first <dependencies> tag of pom file"""

def getDependencyNames(dirName, filename):

	root = initXML(dirName, filename)
	dependency=[]
	dependencyTag = None
	if root.tag == "dependencies":
		dependencyTag = root
	else:
		dependencyTag = root.find('dependencies')

	if dependencyTag is not None:
		for child in dependencyTag:
			if child.tag == "dependency":
				dependencyInfo = {}
				dependencyInfo["groupId"]=""	
				dependencyInfo["artifactId"]=""	
				dependencyInfo["version"]=""	
				dependencyInfo["scope"]=""	
				for subchild in child:
					if subchild.tag == "groupId":
						dependencyInfo["groupId"]=subchild.text

					if subchild.tag == "artifactId":
						dependencyInfo["artifactId"]=subchild.text
					
					if subchild.tag == "version":
						dependencyInfo["version"]=subchild.text

					if subchild.tag == "scope":
						dependencyInfo["scope"]=subchild.text

				dependency.append(dependencyInfo)

	# find dependencies from the pluginmanagement tag
	buildTag = None
	if root.tag == "build":
		buildTag = root
	else:
		buildTag = root.find('build')

	if buildTag is not None:
		pass
	else :
		return dependency

	for pluginManagementTags in buildTag.findall('pluginManagement'):
		for pluginsTags in pluginManagementTags.findall('plugins'):
			for pluginTags in pluginsTags.findall('plugin'):
				for dependenciesTags in pluginTags.findall('dependencies'):
					for child in dependenciesTags:
						if child.tag == "dependency":
							dependencyInfo = {}
							dependencyInfo["groupId"]=""	
							dependencyInfo["artifactId"]=""	
							dependencyInfo["version"]=""	
							dependencyInfo["scope"]=""	
							for subchild in child:
								if subchild.tag == "groupId":
									dependencyInfo["groupId"]=subchild.text

								if subchild.tag == "artifactId":
									dependencyInfo["artifactId"]=subchild.text
								
								if subchild.tag == "version":
									dependencyInfo["version"]=subchild.text

								if subchild.tag == "scope":
									dependencyInfo["scope"]=subchild.text
							dependency.append(dependencyInfo)

	return dependency

"""Returns the names of the major modules/projects parents in the pom file under the first <parent> tag of the pom file"""
def getParentNames(dirName, filename):
	root = initXML(dirName, filename)
	parent = []
	#makes modules as the root tag
	if root.tag == "parent":
		pass
	else:
		root = root.find('parent')

	if root is not None:
		pass
	else :
		return parent
	
	parentInfo = {}
	
	for child in root:
		if child.tag == 'groupId':
			parentInfo["groupId"] = child.text
		if child.tag == 'artifactId':
			parentInfo["artifactId"] = child.text
		if child.tag == 'version':
			parentInfo["version"] = child.text
	parent.append(parentInfo)

	return parent

"""Returns the names of the major modules/projects parents in the pom file"""
def getPomName(dirName, filename):
	root = initXML(dirName, filename)
	if root.tag == "name":
		pass
	else:
		root = root.find('name')
	if root is not None:
		return root.text
	else :
		return ""

"""Recurse over all pom files of the module in the autorelease"""
def recursePom(directoryName):

	recursePomInfo = []
	for dirName, subdirList, fileList in os.walk(directoryName):
		#skipping all src and target directories
	    # if dirName=="src" or dirName=="target" or dirName==directoryName:
	    # 	continue;
	    for fname in fileList:
	        if fname == 'pom.xml' :
	        	systemCallMvnEffectivePom( dirName )
	        	fname = 'epom.xml'
	        	if os.path.isfile( dirName + '/' + fname ) :
	        		pass
	        	else :
	        		continue
	        	pomExtractedInfo = {}
	        	pomExtractedInfo['path'] = dirName + '/' + fname
	        	pomExtractedInfo['name'] = getPomName(dirName, fname)
	        	pomExtractedInfo['id'] = getUniqueId(dirName, fname)
	        	pomExtractedInfo['modules'] = getModuleNames(dirName, fname)
	        	pomExtractedInfo['dependencies'] = getDependencyNames(dirName, fname)
	        	pomExtractedInfo['parent'] = getParentNames(dirName, fname)
	        	recursePomInfo.append(pomExtractedInfo)
	return recursePomInfo

"""Tells whether the pom files exists or not"""
def checkPomfileExistence(fname):
	return os.path.isfile(fname) 

def getID(node):
	return node['id']['groupId'] + ':' + node['id']['artifactId'] + ':' + node['id']['version']

def filterInfo(name):
	return re.sub("org.opendaylight.", "", name)

def getDependencyGroupID(node):
	return node['groupId']

def getDependencyVersion(node):
	return node['version']

"""Checks whether a module is valid opendaylight module or not"""

def checkValidModule(moduleName):

	if re.search( "^org\.opendaylight", moduleName ) :
		return True
	else :
		return False

"""Return the project in which the module is found"""

def findProjectOfModule(projectMapping, module):

	module = re.sub('org.opendaylight.', '', module)
	module = re.sub('\..*$', '', module)
	return module

def getLabel(node):
	return getID(node)
	if node['name'] != "" :
		return node['name']
	else:
		return getID(node)

def helperExtendDependencyInformation(projectMappedToAllModules, anticipatedNodes, anticipatedEdges, distinctIdLabelFromEdges, dependency, project):

	if checkValidModule( getDependencyGroupID( dependency ) ) :
		pass
	else :
		return

	distinctIdLabelFromEdges.append( project )
	distinctIdLabelFromEdges.append(
		findProjectOfModule( projectMappedToAllModules,
		getDependencyGroupID( dependency ) )
	)
	
	anticipatedEdges.append({
		'from': project, 
		'to': findProjectOfModule( projectMappedToAllModules, getDependencyGroupID( dependency ) ),
		'arrows': 'to'
	})

	return

def extendDependencyInformation(projectMappedToAllModules, anticipatedNodes, anticipatedEdges, distinctIdLabelFromEdges, submodule, project):

	for dependency in submodule['dependencies'] :
		helperExtendDependencyInformation(projectMappedToAllModules, anticipatedNodes, anticipatedEdges, distinctIdLabelFromEdges, dependency, project)
	for dependency in submodule['parent'] :
		helperExtendDependencyInformation(projectMappedToAllModules, anticipatedNodes, anticipatedEdges, distinctIdLabelFromEdges, dependency, project)

	return


def extendModulesMappedToProjects(dependency, modulesMappedToProjects, submodule, project):
	
	moduleName = '(' + dependency['groupId'] + ", " + dependency['artifactId'] + ')'
	pomFile = submodule['path']
	dependencyVersion = getDependencyVersion( dependency )
	dependencyProject = project # the project that's dependant on the concerned module
	if moduleName in modulesMappedToProjects.keys():
		if dependencyProject in modulesMappedToProjects[moduleName].keys():
			modulesMappedToProjects[moduleName][dependencyProject].append( (dependencyVersion, pomFile) )
		else:
			modulesMappedToProjects[moduleName][dependencyProject] = []
			modulesMappedToProjects[moduleName][dependencyProject].append( (dependencyVersion, pomFile) )
	else:
		modulesMappedToProjects[moduleName] = {}
		modulesMappedToProjects[moduleName][dependencyProject] = []
		modulesMappedToProjects[moduleName][dependencyProject].append( (dependencyVersion, pomFile) )

	return

def main():

	DIR_LOC = sys.argv[1]

	systemCallMvnEffectivePom( DIR_LOC )

	rootPomFile = "epom.xml"
	dependencies = {}
	dependencies['path'] = DIR_LOC + '/' + rootPomFile
	dependencies['id'] = getUniqueId(DIR_LOC, rootPomFile)
	dependencies['name'] = getPomName(DIR_LOC, rootPomFile)
	dependencies['dependencies'] = getDependencyNames(DIR_LOC, rootPomFile)
	dependencies['parent'] = getParentNames(DIR_LOC, rootPomFile)
	dependencies['modules'] = getModuleNames(DIR_LOC, rootPomFile)
	dependencies['moduleInfo'] = {}
	actualModules = []

	for module in dependencies['modules']:
		moduleDir = DIR_LOC+'/'+module
		rootPomFile = "pom.xml"
		if checkPomfileExistence(moduleDir + '/' + rootPomFile) :
			pass
		else :
			continue
		systemCallMvnEffectivePom( moduleDir )
		rootPomFile = "epom.xml"
		if checkPomfileExistence(moduleDir + '/' + rootPomFile) :
			pass
		else :
			continue
		actualModules.append( module )
		dependencies['moduleInfo'][module] = {}
		dependencies['moduleInfo'][module]['id'] = getUniqueId( moduleDir, rootPomFile )
		dependencies['moduleInfo'][module]['name'] = getPomName( moduleDir, rootPomFile )
		dependencies['moduleInfo'][module]['modules'] = getModuleNames( moduleDir, rootPomFile )
		dependencies['moduleInfo'][module]['dependencies'] = getDependencyNames( moduleDir, rootPomFile )
		dependencies['moduleInfo'][module]['parent'] = getParentNames( moduleDir, rootPomFile )
		dependencies['moduleInfo'][module]["recursePomInfo"] = recursePom( moduleDir )

	dependencies['modules'] = actualModules

	projectMappedToAllModules = {}

	for project in actualModules :
		allModules = []
		allModules.extend(dependencies['moduleInfo'][project]['modules'])
		for data in dependencies['moduleInfo'][project]['recursePomInfo'] :
			allModules.extend(data['modules'])
			allModules.append(getID(data))
		projectMappedToAllModules[project] = allModules

	distinctIdLabel = []

	distinctIdLabel.append(getID(dependencies))

	for module in dependencies['modules'] :
		distinctIdLabel.append(getID(dependencies['moduleInfo'][module]))

		for submodule in dependencies['moduleInfo'][module]['recursePomInfo'] :
			distinctIdLabel.append(getID(submodule))

	distinctIdLabel = set(distinctIdLabel)

	anticipatedEdges = []
	anticipatedNodes = []

	distinctIdLabelFromEdges = []

	extendDependencyInformation(projectMappedToAllModules, anticipatedNodes, anticipatedEdges, distinctIdLabelFromEdges, dependencies, dependencies['name'])

	for project in dependencies['modules'] :
		for submodule in dependencies['moduleInfo'][project]['recursePomInfo'] :
			extendDependencyInformation(projectMappedToAllModules, anticipatedNodes, anticipatedEdges, distinctIdLabelFromEdges, submodule, project)

	distinctIdLabelFromEdges = set(distinctIdLabelFromEdges)

	for idLabel in distinctIdLabelFromEdges :
		anticipatedNodes.append({
			'id': idLabel,
			'label': idLabel
		})

	#set of unique edges
	anticipatedEdges = [dict(t) for t in set([tuple(d.items()) for d in anticipatedEdges])]

	modulesMappedToProjects = {}

	#For Parent Node
	for dependency in dependencies['dependencies'] :
		extendModulesMappedToProjects(dependency, modulesMappedToProjects, dependencies, dependencies['name'])

	#For Root Nodes
	for project in dependencies['modules'] :

		for submodule in dependencies['moduleInfo'][project]['recursePomInfo'] :

			for dependency in submodule['dependencies'] :
				extendModulesMappedToProjects(dependency, modulesMappedToProjects, submodule, project)

			for dependency in submodule['parent'] :
				extendModulesMappedToProjects(dependency, modulesMappedToProjects, submodule, project)

	stringEdges = 'var edges = ' + json.dumps(anticipatedEdges) + '\n'

	stringNodes = 'var nodes = '+ json.dumps(anticipatedNodes) + '\n'

	stringModulesMappedToProjects = 'var modulesMappedToProjects = ' + json.dumps(modulesMappedToProjects) + '\n'

	f = open('./dependencyInfo.json', 'w')

	f.write(stringNodes)
	f.write(stringEdges)
	f.write(stringModulesMappedToProjects)

if __name__ == "__main__":
    main()

