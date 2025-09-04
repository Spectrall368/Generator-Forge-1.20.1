package net.mcreator.packloader;

import net.minecraftforge.fml.loading.FMLPaths;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.event.AddPackFindersEvent;

import net.minecraft.server.packs.repository.PackSource;
import net.minecraft.server.packs.repository.FolderRepositorySource;
import net.minecraft.server.packs.PackType;

import java.nio.file.Path;

@Mod(PackLoaderMod.MODID) public class PackLoaderMod {

	public static final String MODID = "packloader";

	public PackLoaderMod(FMLJavaModLoadingContext context) {
		context.getModEventBus().addListener(this::addPacks);
	}

	public void addPacks(AddPackFindersEvent event) {
		event.addRepositorySource(new FolderRepositorySource(FMLPaths.getOrCreateGameRelativePath(Path.of("datapacks")),
				PackType.SERVER_DATA, PackSource.DEFAULT));
	}

}
