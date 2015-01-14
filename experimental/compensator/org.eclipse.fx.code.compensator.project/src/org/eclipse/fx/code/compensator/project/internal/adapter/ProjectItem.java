package org.eclipse.fx.code.compensator.project.internal.adapter;

import java.util.List;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;

import org.eclipse.fx.code.compensator.model.workbench.LocalProject;
import org.eclipse.fx.code.compensator.project.InstanceProject;
import org.eclipse.fx.code.compensator.project.ProjectNavigatorItem;
import org.eclipse.fx.code.compensator.project.vcs.VersionControlService;
import org.eclipse.fx.core.FilesystemService;
import org.eclipse.fx.core.SimpleURI;
import org.eclipse.fx.core.URI;

public class ProjectItem implements ProjectNavigatorItem {
	private final InstanceProject project;
	private final ObservableList<ProjectNavigatorItem> children = FXCollections.observableArrayList();

	public ProjectItem(InstanceProject project, VersionControlService versionControl, List<FilesystemService> fileSystemServiceList) {
		this.project = project;
		children.add(new ModuleContainerItem(project));
		children.add(new BugtrackerItem());
		children.add(new BuildServerItem());
		if( project.getProject() instanceof LocalProject ) {
			LocalProject lp = (LocalProject) project.getProject();
			URI uri = new SimpleURI(lp.getLocalURI());
			children.add(new VCSContainerItem(lp, versionControl,fileSystemServiceList.stream().filter(s -> s.applies(uri)).findFirst().get()));
		}
	}

	@Override
	public CharSequence getLabel() {
		return project.getProject().getName();
	}

	@Override
	public String getIcon() {
		return "platform:/plugin/org.eclipse.fx.code.compensator.project/css/icons/16/module_view.png";
	}

	@Override
	public Object getDomainObject() {
		return project;
	}

	@Override
	public String getOpenCommandId() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean isDeletable() {
		return true;
	}

	@Override
	public ObservableList<ProjectNavigatorItem> getChildren() {
		return children;
	}

	@Override
	public boolean isLeaf() {
		return false;
	}
}
