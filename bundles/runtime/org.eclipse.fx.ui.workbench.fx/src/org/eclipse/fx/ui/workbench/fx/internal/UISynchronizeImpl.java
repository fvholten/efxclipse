/*******************************************************************************
 * Copyright (c) 2014 EM-SOFTWARE and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Christoph Keimel <c.keimel@emsw.de> - initial API and implementation
 *******************************************************************************/
package org.eclipse.fx.ui.workbench.fx.internal;

import java.util.concurrent.Callable;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.FutureTask;
import java.util.concurrent.RunnableFuture;
import java.util.concurrent.atomic.AtomicBoolean;

import org.eclipse.fx.core.Subscription;
import org.eclipse.fx.core.ThreadSynchronize;
import org.eclipse.fx.core.log.Logger;
import org.eclipse.fx.core.log.LoggerFactory;
import org.eclipse.fx.ui.services.sync.UISynchronize;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.annotations.ReferencePolicyOption;

import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.util.Duration;

/**
 * Implementation of the UISynchronize service for JavaFX
 */
@Component(service = { UISynchronize.class, org.eclipse.e4.ui.di.UISynchronize.class, ThreadSynchronize.class })
public class UISynchronizeImpl extends org.eclipse.e4.ui.di.UISynchronize implements UISynchronize {
	private LoggerFactory factory;
	private Logger logger;

	/**
	 * Setting a new factory
	 *
	 * @param factory
	 *            the new factory
	 */
	@Reference(policy = ReferencePolicy.DYNAMIC, policyOption = ReferencePolicyOption.GREEDY)
	public void setLoggerFactory(LoggerFactory factory) {
		this.factory = factory;
		this.logger = null;
	}

	/**
	 * Unset the logger factory
	 *
	 * @param factory
	 *            the factory
	 */
	public void unsetLoggerFactory(LoggerFactory factory) {
		if (this.factory == factory) {
			this.factory = null;
			this.logger = null;
		}
	}

	@SuppressWarnings("null")
	private Logger getLogger() {
		if (this.logger == null) {
			this.logger = this.factory.createLogger(getClass().getName());
		}
		return this.logger;
	}

	@Override
	public <V> V syncExec(final Callable<V> callable, V defaultValue) {
		if (javafx.application.Platform.isFxApplicationThread()) {
			try {
				return callable.call();
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		} else {
			RunnableFuture<V> task = new FutureTask<V>(callable);
			javafx.application.Platform.runLater(task);
			try {
				return task.get();
			} catch (InterruptedException | ExecutionException e) {
				getLogger().error("Unable to wait until the task is completed", e); //$NON-NLS-1$
			} finally {
				task.cancel(true);
			}
		}
		return defaultValue;
	}

	@Override
	public void syncExec(final Runnable runnable) {
		if (javafx.application.Platform.isFxApplicationThread()) {
			runnable.run();
		} else {
			RunnableFuture<?> task = new FutureTask<Void>(runnable, null);
			javafx.application.Platform.runLater(task);
			try {
				task.get(); // wait for task to complete
			} catch (InterruptedException | ExecutionException e) {
				getLogger().error("Unable to wait until the task is completed", e); //$NON-NLS-1$
			} finally {
				task.cancel(true);
			}
		}
	}

	@Override
	public <V> Future<V> asyncExec(final Callable<V> callable) {
		RunnableFuture<V> task = new FutureTask<V>(callable);
		javafx.application.Platform.runLater(task);
		return task;
	}

	@Override
	public void asyncExec(Runnable runnable) {
		javafx.application.Platform.runLater(runnable);
	}

	@Override
	public Subscription scheduleExecution(long delay, Runnable runnable) {
		final AtomicBoolean b = new AtomicBoolean(true);
		Timeline t = new Timeline(new KeyFrame(Duration.millis(delay), (a) -> {
			if (b.get()) {
				runnable.run();
			}
		}));
		t.play();
		return new Subscription() {

			@Override
			public void dispose() {
				b.set(false);
				t.stop();
			}
		};
	}

	@Override
	public <T> CompletableFuture<T> scheduleExecution(long delay, Callable<T> runnable) {
		CompletableFuture<T> future = new CompletableFuture<T>();

		Timeline t = new Timeline(new KeyFrame(Duration.millis(delay), (a) -> {
			try {
				if (!future.isCancelled()) {
					future.complete(runnable.call());
				}
			} catch (Exception e) {
				future.completeExceptionally(e);
			}
		}));
		t.play();

		return future;
	}

}
